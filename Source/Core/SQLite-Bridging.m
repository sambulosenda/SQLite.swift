//
// SQLite.swift
// https://github.com/stephencelis/SQLite.swift
// Copyright © 2014-2015 Stephen Celis.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "SQLite-Bridging.h"

#import "fts3_tokenizer.h"

static int __SQLiteBusyHandler(void * context, int tries) {
    return ((__bridge _SQLiteBusyHandlerCallback)context)(tries);
}

int _SQLiteBusyHandler(sqlite3 * db, _SQLiteBusyHandlerCallback callback) {
    if (callback) {
        return sqlite3_busy_handler(db, __SQLiteBusyHandler, (__bridge void *)callback);
    } else {
        return sqlite3_busy_handler(db, 0, 0);
    }
}

static void __SQLiteTrace(void * context, const char * SQL) {
    ((__bridge _SQLiteTraceCallback)context)(SQL);
}

void _SQLiteTrace(sqlite3 * db, _SQLiteTraceCallback callback) {
    if (callback) {
        sqlite3_trace(db, __SQLiteTrace, (__bridge void *)callback);
    } else {
        sqlite3_trace(db, 0, 0);
    }
}

static void __SQLiteUpdateHook(void * context, int operation, const char * db, const char * table, long long rowid) {
    ((__bridge _SQLiteUpdateHookCallback)context)(operation, db, table, rowid);
}

void _SQLiteUpdateHook(sqlite3 * db, _SQLiteUpdateHookCallback callback) {
    sqlite3_update_hook(db, __SQLiteUpdateHook, (__bridge void *)callback);
}

static int __SQLiteCommitHook(void * context) {
    return ((__bridge _SQLiteCommitHookCallback)context)();
}

void _SQLiteCommitHook(sqlite3 * db, _SQLiteCommitHookCallback callback) {
    sqlite3_commit_hook(db, __SQLiteCommitHook, (__bridge void *)callback);
}

static void __SQLiteRollbackHook(void * context) {
    ((__bridge void (^ _Null_unspecified )())context)();
}

void _SQLiteRollbackHook(sqlite3 * db, void (^ _Null_unspecified callback)()) {
    sqlite3_rollback_hook(db, __SQLiteRollbackHook, (__bridge void *)callback);
}

static void __SQLiteCreateFunction(sqlite3_context * context, int argc, sqlite3_value ** argv) {
    ((__bridge _SQLiteCreateFunctionCallback)sqlite3_user_data(context))(context, argc, argv);
}

int _SQLiteCreateFunction(sqlite3 * db, const char * name, int argc, int deterministic, _SQLiteCreateFunctionCallback callback) {
    if (callback) {
        int flags = SQLITE_UTF8;
        if (deterministic) {
#ifdef SQLITE_DETERMINISTIC
            flags |= SQLITE_DETERMINISTIC;
#endif
        }
        return sqlite3_create_function_v2(db, name, -1, flags, (__bridge void *)callback, &__SQLiteCreateFunction, 0, 0, 0);
    } else {
        return sqlite3_create_function_v2(db, name, 0, 0, 0, 0, 0, 0, 0);
    }
}

static int __SQLiteCreateCollation(void * context, int len_lhs, const void * lhs, int len_rhs, const void * rhs) {
    return ((__bridge _SQLiteCreateCollationCallback)context)(lhs, rhs);
}

int _SQLiteCreateCollation(sqlite3 * db, const char * name, _SQLiteCreateCollationCallback callback) {
    if (callback) {
        return sqlite3_create_collation_v2(db, name, SQLITE_UTF8, (__bridge void *)callback, &__SQLiteCreateCollation, 0);
    } else {
        return sqlite3_create_collation_v2(db, name, 0, 0, 0, 0);
    }
}

#pragma mark - FTS

typedef struct __SQLiteTokenizer {
    sqlite3_tokenizer base;
    __unsafe_unretained _SQLiteTokenizerNextCallback callback;
} __SQLiteTokenizer;

typedef struct __SQLiteTokenizerCursor {
    void * base;
    const char * input;
    int inputOffset;
    int inputLength;
    int idx;
} __SQLiteTokenizerCursor;

static NSMutableDictionary * __SQLiteTokenizerMap;

static int __SQLiteTokenizerCreate(int argc, const char * const * argv, sqlite3_tokenizer ** ppTokenizer) {
    __SQLiteTokenizer * tokenizer = (__SQLiteTokenizer *)sqlite3_malloc(sizeof(__SQLiteTokenizer));
    if (!tokenizer) {
        return SQLITE_NOMEM;
    }
    memset(tokenizer, 0, sizeof(* tokenizer)); // FIXME: needed?

    NSString * key = [NSString stringWithUTF8String:argv[0]];
    tokenizer->callback = [__SQLiteTokenizerMap objectForKey:key];
    if (!tokenizer->callback) {
        return SQLITE_ERROR;
    }

    *ppTokenizer = &tokenizer->base;
    return SQLITE_OK;
}

static int __SQLiteTokenizerDestroy(sqlite3_tokenizer * pTokenizer) {
    sqlite3_free(pTokenizer);
    return SQLITE_OK;
}

static int __SQLiteTokenizerOpen(sqlite3_tokenizer * pTokenizer, const char * pInput, int nBytes, sqlite3_tokenizer_cursor ** ppCursor) {
    __SQLiteTokenizerCursor * cursor = (__SQLiteTokenizerCursor *)sqlite3_malloc(sizeof(__SQLiteTokenizerCursor));
    if (!cursor) {
        return SQLITE_NOMEM;
    }

    cursor->input = pInput;
    cursor->inputOffset = 0;
    cursor->inputLength = 0;
    cursor->idx = 0;

    *ppCursor = (sqlite3_tokenizer_cursor *)cursor;
    return SQLITE_OK;
}

static int __SQLiteTokenizerClose(sqlite3_tokenizer_cursor * pCursor) {
    sqlite3_free(pCursor);
    return SQLITE_OK;
}

static int __SQLiteTokenizerNext(sqlite3_tokenizer_cursor * pCursor, const char ** ppToken, int * pnBytes, int * piStartOffset, int * piEndOffset, int * piPosition) {
    __SQLiteTokenizerCursor * cursor = (__SQLiteTokenizerCursor *)pCursor;
    __SQLiteTokenizer * tokenizer = (__SQLiteTokenizer *)cursor->base;

    cursor->inputOffset += cursor->inputLength;
    const char * input = cursor->input + cursor->inputOffset;
    const char * token = [tokenizer->callback(input, &cursor->inputOffset, &cursor->inputLength) cStringUsingEncoding:NSUTF8StringEncoding];
    if (!token) {
        return SQLITE_DONE;
    }

    *ppToken = token;
    *pnBytes = (int)strlen(token);
    *piStartOffset = cursor->inputOffset;
    *piEndOffset = cursor->inputOffset + cursor->inputLength;
    *piPosition = cursor->idx++;
    return SQLITE_OK;
}

static const sqlite3_tokenizer_module __SQLiteTokenizerModule = {
    0,
    __SQLiteTokenizerCreate,
    __SQLiteTokenizerDestroy,
    __SQLiteTokenizerOpen,
    __SQLiteTokenizerClose,
    __SQLiteTokenizerNext
};

int _SQLiteRegisterTokenizer(sqlite3 * db, const char * moduleName, const char * submoduleName, _SQLiteTokenizerNextCallback callback) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __SQLiteTokenizerMap = [NSMutableDictionary new];
    });

    sqlite3_stmt * stmt;
    int status = sqlite3_prepare_v2(db, "SELECT fts3_tokenizer(?, ?)", -1, &stmt, 0);
    if (status != SQLITE_OK ){
        return status;
    }
    const sqlite3_tokenizer_module * pModule = &__SQLiteTokenizerModule;
    sqlite3_bind_text(stmt, 1, moduleName, -1, SQLITE_STATIC);
    sqlite3_bind_blob(stmt, 2, &pModule, sizeof(pModule), SQLITE_STATIC);
    sqlite3_step(stmt);
    status = sqlite3_finalize(stmt);
    if (status != SQLITE_OK ){
        return status;
    }

    [__SQLiteTokenizerMap setObject:[callback copy] forKey:[NSString stringWithUTF8String:submoduleName]];

    return SQLITE_OK;
}
