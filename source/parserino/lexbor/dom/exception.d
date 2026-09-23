module parserino.lexbor.dom.exception;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;

extern(C) @nogc nothrow:
__gshared:

// ---- exception.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum lxb_dom_exception_code_t {
    LXB_DOM_INDEX_SIZE_ERR = 0x00,
    LXB_DOM_DOMSTRING_SIZE_ERR,
    LXB_DOM_HIERARCHY_REQUEST_ERR,
    LXB_DOM_WRONG_DOCUMENT_ERR,
    LXB_DOM_INVALID_CHARACTER_ERR,
    LXB_DOM_NO_DATA_ALLOWED_ERR,
    LXB_DOM_NO_MODIFICATION_ALLOWED_ERR,
    LXB_DOM_NOT_FOUND_ERR,
    LXB_DOM_NOT_SUPPORTED_ERR,
    LXB_DOM_INUSE_ATTRIBUTE_ERR,
    LXB_DOM_INVALID_STATE_ERR,
    LXB_DOM_SYNTAX_ERR,
    LXB_DOM_INVALID_MODIFICATION_ERR,
    LXB_DOM_NAMESPACE_ERR,
    LXB_DOM_INVALID_ACCESS_ERR,
    LXB_DOM_VALIDATION_ERR,
    LXB_DOM_TYPE_MISMATCH_ERR,
    LXB_DOM_SECURITY_ERR,
    LXB_DOM_NETWORK_ERR,
    LXB_DOM_ABORT_ERR,
    LXB_DOM_URL_MISMATCH_ERR,
    LXB_DOM_QUOTA_EXCEEDED_ERR,
    LXB_DOM_TIMEOUT_ERR,
    LXB_DOM_INVALID_NODE_TYPE_ERR,
    LXB_DOM_DATA_CLONE_ERR
}
alias LXB_DOM_INDEX_SIZE_ERR = lxb_dom_exception_code_t.LXB_DOM_INDEX_SIZE_ERR;
alias LXB_DOM_DOMSTRING_SIZE_ERR = lxb_dom_exception_code_t.LXB_DOM_DOMSTRING_SIZE_ERR;
alias LXB_DOM_HIERARCHY_REQUEST_ERR = lxb_dom_exception_code_t.LXB_DOM_HIERARCHY_REQUEST_ERR;
alias LXB_DOM_WRONG_DOCUMENT_ERR = lxb_dom_exception_code_t.LXB_DOM_WRONG_DOCUMENT_ERR;
alias LXB_DOM_INVALID_CHARACTER_ERR = lxb_dom_exception_code_t.LXB_DOM_INVALID_CHARACTER_ERR;
alias LXB_DOM_NO_DATA_ALLOWED_ERR = lxb_dom_exception_code_t.LXB_DOM_NO_DATA_ALLOWED_ERR;
alias LXB_DOM_NO_MODIFICATION_ALLOWED_ERR = lxb_dom_exception_code_t.LXB_DOM_NO_MODIFICATION_ALLOWED_ERR;
alias LXB_DOM_NOT_FOUND_ERR = lxb_dom_exception_code_t.LXB_DOM_NOT_FOUND_ERR;
alias LXB_DOM_NOT_SUPPORTED_ERR = lxb_dom_exception_code_t.LXB_DOM_NOT_SUPPORTED_ERR;
alias LXB_DOM_INUSE_ATTRIBUTE_ERR = lxb_dom_exception_code_t.LXB_DOM_INUSE_ATTRIBUTE_ERR;
alias LXB_DOM_INVALID_STATE_ERR = lxb_dom_exception_code_t.LXB_DOM_INVALID_STATE_ERR;
alias LXB_DOM_SYNTAX_ERR = lxb_dom_exception_code_t.LXB_DOM_SYNTAX_ERR;
alias LXB_DOM_INVALID_MODIFICATION_ERR = lxb_dom_exception_code_t.LXB_DOM_INVALID_MODIFICATION_ERR;
alias LXB_DOM_NAMESPACE_ERR = lxb_dom_exception_code_t.LXB_DOM_NAMESPACE_ERR;
alias LXB_DOM_INVALID_ACCESS_ERR = lxb_dom_exception_code_t.LXB_DOM_INVALID_ACCESS_ERR;
alias LXB_DOM_VALIDATION_ERR = lxb_dom_exception_code_t.LXB_DOM_VALIDATION_ERR;
alias LXB_DOM_TYPE_MISMATCH_ERR = lxb_dom_exception_code_t.LXB_DOM_TYPE_MISMATCH_ERR;
alias LXB_DOM_SECURITY_ERR = lxb_dom_exception_code_t.LXB_DOM_SECURITY_ERR;
alias LXB_DOM_NETWORK_ERR = lxb_dom_exception_code_t.LXB_DOM_NETWORK_ERR;
alias LXB_DOM_ABORT_ERR = lxb_dom_exception_code_t.LXB_DOM_ABORT_ERR;
alias LXB_DOM_URL_MISMATCH_ERR = lxb_dom_exception_code_t.LXB_DOM_URL_MISMATCH_ERR;
alias LXB_DOM_QUOTA_EXCEEDED_ERR = lxb_dom_exception_code_t.LXB_DOM_QUOTA_EXCEEDED_ERR;
alias LXB_DOM_TIMEOUT_ERR = lxb_dom_exception_code_t.LXB_DOM_TIMEOUT_ERR;
alias LXB_DOM_INVALID_NODE_TYPE_ERR = lxb_dom_exception_code_t.LXB_DOM_INVALID_NODE_TYPE_ERR;
alias LXB_DOM_DATA_CLONE_ERR = lxb_dom_exception_code_t.LXB_DOM_DATA_CLONE_ERR;


/*
 * Inline functions
 */
 void* lxb_dom_exception_code_ref_set(lxb_dom_exception_code_t* var, lxb_dom_exception_code_t code)
{
    if (var != null) {
        *var = code;
    }

    return null;
}

/*
 * No inline functions for ABI.
 */

// D port: implementation not needed by parserino, not ported.
