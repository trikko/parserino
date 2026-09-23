module parserino.lexbor.dom.exception;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;
public import parserino.lexbor.core.str;
public import parserino.lexbor.dom.interface_;
import parserino.lexbor.dom.interfaces.document;

extern(C) @nogc nothrow:
__gshared:

// ---- exception.h ----
/*
 * Copyright (C) 2018-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum lxb_dom_exception_code_t {
    LXB_DOM_EXCEPTION_OK = -1,
    LXB_DOM_EXCEPTION_ERR = 0,
    LXB_DOM_EXCEPTION_INDEX_SIZE_ERR = 1, /* Deprecated. */
    LXB_DOM_EXCEPTION_DOMSTRING_SIZE_ERR,
    LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR,
    LXB_DOM_EXCEPTION_WRONG_DOCUMENT_ERR,
    LXB_DOM_EXCEPTION_INVALID_CHARACTER_ERR,
    LXB_DOM_EXCEPTION_NO_DATA_ALLOWED_ERR,
    LXB_DOM_EXCEPTION_NO_MODIFICATION_ALLOWED_ERR,
    LXB_DOM_EXCEPTION_NOT_FOUND_ERR,
    LXB_DOM_EXCEPTION_NOT_SUPPORTED_ERR,
    LXB_DOM_EXCEPTION_INUSE_ATTRIBUTE_ERR,
    LXB_DOM_EXCEPTION_INVALID_STATE_ERR,
    LXB_DOM_EXCEPTION_SYNTAX_ERR,
    LXB_DOM_EXCEPTION_INVALID_MODIFICATION_ERR,
    LXB_DOM_EXCEPTION_NAMESPACE_ERR,
    LXB_DOM_EXCEPTION_INVALID_ACCESS_ERR, /* Deprecated. */
    LXB_DOM_EXCEPTION_VALIDATION_ERR,
    LXB_DOM_EXCEPTION_TYPE_MISMATCH_ERR, /* Deprecated. */
    LXB_DOM_EXCEPTION_SECURITY_ERR,
    LXB_DOM_EXCEPTION_NETWORK_ERR,
    LXB_DOM_EXCEPTION_ABORT_ERR,
    LXB_DOM_EXCEPTION_URL_MISMATCH_ERR, /* Deprecated. */
    LXB_DOM_EXCEPTION_QUOTA_EXCEEDED_ERR, /* Deprecated. */
    LXB_DOM_EXCEPTION_TIMEOUT_ERR,
    LXB_DOM_EXCEPTION_INVALID_NODE_TYPE_ERR,
    LXB_DOM_EXCEPTION_DATA_CLONE_ERR,
    LXB_DOM_EXCEPTION_ENCODING_ERR,
    LXB_DOM_EXCEPTION_NOT_READABLE_ERR,
    LXB_DOM_EXCEPTION_UNKNOWN_ERR,
    LXB_DOM_EXCEPTION_CONSTRAINT_ERR,
    LXB_DOM_EXCEPTION_DATA_ERR,
    LXB_DOM_EXCEPTION_TRANSACTION_INACTIVE_ERR,
    LXB_DOM_EXCEPTION_READ_ONLY_ERR,
    LXB_DOM_EXCEPTION_VERSION_ERR,
    LXB_DOM_EXCEPTION_OPERATION_ERR,
    LXB_DOM_EXCEPTION_NOT_ALLOWED_ERR,
    LXB_DOM_EXCEPTION_OPT_OUT_ERR,
    LXB_DOM_EXCEPTION__LAST_ENTRY
}
alias LXB_DOM_EXCEPTION_OK = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_OK;
alias LXB_DOM_EXCEPTION_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_ERR;
alias LXB_DOM_EXCEPTION_INDEX_SIZE_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_INDEX_SIZE_ERR;
alias LXB_DOM_EXCEPTION_DOMSTRING_SIZE_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_DOMSTRING_SIZE_ERR;
alias LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR;
alias LXB_DOM_EXCEPTION_WRONG_DOCUMENT_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_WRONG_DOCUMENT_ERR;
alias LXB_DOM_EXCEPTION_INVALID_CHARACTER_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_INVALID_CHARACTER_ERR;
alias LXB_DOM_EXCEPTION_NO_DATA_ALLOWED_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_NO_DATA_ALLOWED_ERR;
alias LXB_DOM_EXCEPTION_NO_MODIFICATION_ALLOWED_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_NO_MODIFICATION_ALLOWED_ERR;
alias LXB_DOM_EXCEPTION_NOT_FOUND_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_NOT_FOUND_ERR;
alias LXB_DOM_EXCEPTION_NOT_SUPPORTED_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_NOT_SUPPORTED_ERR;
alias LXB_DOM_EXCEPTION_INUSE_ATTRIBUTE_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_INUSE_ATTRIBUTE_ERR;
alias LXB_DOM_EXCEPTION_INVALID_STATE_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_INVALID_STATE_ERR;
alias LXB_DOM_EXCEPTION_SYNTAX_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_SYNTAX_ERR;
alias LXB_DOM_EXCEPTION_INVALID_MODIFICATION_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_INVALID_MODIFICATION_ERR;
alias LXB_DOM_EXCEPTION_NAMESPACE_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_NAMESPACE_ERR;
alias LXB_DOM_EXCEPTION_INVALID_ACCESS_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_INVALID_ACCESS_ERR;
alias LXB_DOM_EXCEPTION_VALIDATION_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_VALIDATION_ERR;
alias LXB_DOM_EXCEPTION_TYPE_MISMATCH_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_TYPE_MISMATCH_ERR;
alias LXB_DOM_EXCEPTION_SECURITY_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_SECURITY_ERR;
alias LXB_DOM_EXCEPTION_NETWORK_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_NETWORK_ERR;
alias LXB_DOM_EXCEPTION_ABORT_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_ABORT_ERR;
alias LXB_DOM_EXCEPTION_URL_MISMATCH_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_URL_MISMATCH_ERR;
alias LXB_DOM_EXCEPTION_QUOTA_EXCEEDED_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_QUOTA_EXCEEDED_ERR;
alias LXB_DOM_EXCEPTION_TIMEOUT_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_TIMEOUT_ERR;
alias LXB_DOM_EXCEPTION_INVALID_NODE_TYPE_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_INVALID_NODE_TYPE_ERR;
alias LXB_DOM_EXCEPTION_DATA_CLONE_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_DATA_CLONE_ERR;
alias LXB_DOM_EXCEPTION_ENCODING_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_ENCODING_ERR;
alias LXB_DOM_EXCEPTION_NOT_READABLE_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_NOT_READABLE_ERR;
alias LXB_DOM_EXCEPTION_UNKNOWN_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_UNKNOWN_ERR;
alias LXB_DOM_EXCEPTION_CONSTRAINT_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_CONSTRAINT_ERR;
alias LXB_DOM_EXCEPTION_DATA_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_DATA_ERR;
alias LXB_DOM_EXCEPTION_TRANSACTION_INACTIVE_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_TRANSACTION_INACTIVE_ERR;
alias LXB_DOM_EXCEPTION_READ_ONLY_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_READ_ONLY_ERR;
alias LXB_DOM_EXCEPTION_VERSION_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_VERSION_ERR;
alias LXB_DOM_EXCEPTION_OPERATION_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_OPERATION_ERR;
alias LXB_DOM_EXCEPTION_NOT_ALLOWED_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_NOT_ALLOWED_ERR;
alias LXB_DOM_EXCEPTION_OPT_OUT_ERR = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION_OPT_OUT_ERR;
alias LXB_DOM_EXCEPTION__LAST_ENTRY = lxb_dom_exception_code_t.LXB_DOM_EXCEPTION__LAST_ENTRY;


struct lxb_dom_exception_t {
    lexbor_str_t name;
    lexbor_str_t message;
    lxb_dom_exception_code_t code;
    lxb_dom_document_t* document;
}

 lxb_dom_exception_t* lxb_dom_exception_create(lxb_dom_document_t* document, const(lxb_char_t)* message, size_t message_length, const(lxb_char_t)* name, size_t name_length);

 lxb_dom_exception_t* lxb_dom_exception_create_by_code(lxb_dom_document_t* document, const(lxb_char_t)* message, size_t length, lxb_dom_exception_code_t code);

 lxb_dom_exception_t* lxb_dom_exception_destroy(lxb_dom_exception_t* exception);

 const(lexbor_str_t)* lxb_dom_exception_message_by_code(lxb_dom_exception_code_t code);

 const(lexbor_str_t)* lxb_dom_exception_name_by_code(lxb_dom_exception_code_t code);

 lxb_dom_exception_code_t lxb_dom_exception_code_by_name(const(lxb_char_t)* name, size_t length);

// D port: implementation not needed by parserino, not ported.
