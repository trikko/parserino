module parserino.lexbor.selectors.selectors;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.selectors.base;
public import parserino.lexbor.dom.dom;
public import parserino.lexbor.css.selectors.selectors;
public import parserino.lexbor.core.array_obj;
import core.stdc.math;

extern(C) @nogc nothrow:
__gshared:

// ---- selectors.h ----
/*
 * Copyright (C) 2021-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum lxb_selectors_opt_t {
    LXB_SELECTORS_OPT_DEFAULT = 0x00,

    /*
     * Includes the passed (root) node in the search.
     *
     * By default, the root node does not participate in selector searches,
     * only its children.
     *
     * This behavior is logical, if you have found a node and then you want to
     * search for other nodes in it, you don't need to check it again.
     *
     * But there are cases when it is necessary for root node to participate
     * in the search.  That's what this option is for.
     */
    LXB_SELECTORS_OPT_MATCH_ROOT = 1 << 1,

    /*
     * Stop searching after the first match with any of the selectors
     * in the list.
     *
     * By default, the callback will be triggered for each selector list.
     * That is, if your node matches different selector lists, it will be
     * returned multiple times in the callback.
     *
     * For example:
     *    HTML: <div id="ok"><span>test</span></div>
     *    Selectors: div, div[id="ok"], div:has(:not(a))
     *
     * The default behavior will cause three callbacks with the same node (div).
     * Because it will be found by every selector in the list.
     *
     * This option allows you to end the element check after the first match on
     * any of the selectors.  That is, the callback will be called only once
     * for example above.  This way we get rid of duplicates in the search.
     */
    LXB_SELECTORS_OPT_MATCH_FIRST = 1 << 2
}
alias LXB_SELECTORS_OPT_DEFAULT = lxb_selectors_opt_t.LXB_SELECTORS_OPT_DEFAULT;
alias LXB_SELECTORS_OPT_MATCH_ROOT = lxb_selectors_opt_t.LXB_SELECTORS_OPT_MATCH_ROOT;
alias LXB_SELECTORS_OPT_MATCH_FIRST = lxb_selectors_opt_t.LXB_SELECTORS_OPT_MATCH_FIRST;


alias lxb_selectors_t = lxb_selectors;
alias lxb_selectors_entry_t = lxb_selectors_entry;
alias lxb_selectors_nested_t = lxb_selectors_nested;

alias lxb_selectors_cb_f = lxb_status_t function(lxb_dom_node_t* node, lxb_css_selector_specificity_t spec, void* ctx);

alias lxb_selectors_state_cb_f = lxb_selectors_entry_t* function(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry);

struct lxb_selectors_entry {
    uintptr_t id;
    lxb_css_selector_combinator_t combinator;
    const(lxb_css_selector_t)* selector;
    lxb_dom_node_t* node;
    lxb_selectors_entry_t* next;
    lxb_selectors_entry_t* prev;
    lxb_selectors_entry_t* following;
    lxb_selectors_nested_t* nested;
}

struct lxb_selectors_nested {
    lxb_selectors_entry_t* entry;
    lxb_selectors_state_cb_f return_state;

    lxb_selectors_cb_f cb;
    void* ctx;

    lxb_dom_node_t* root;
    lxb_selectors_nested_t* parent;
    lxb_selectors_entry_t* first;
    lxb_selectors_entry_t* top;

    size_t index;

    bool forward;
}

struct lxb_selectors {
    lxb_selectors_state_cb_f state;
    lexbor_dobject_t* objs;
    lexbor_dobject_t* nested;

    lxb_selectors_nested_t* current;

    lxb_selectors_opt_t options;
    lxb_status_t status;
}

/*
 * Create lxb_selectors_t object.
 *
 * @return lxb_selectors_t * if successful, otherwise NULL.
 */

/*
 * Initialization of lxb_selectors_t object.
 *
 * Caches are initialized in this function.
 *
 * @param[in] lxb_selectors_t *
 *
 * @return LXB_STATUS_OK if successful, otherwise an error status value.
 */

/*
 * Clears the object. Returns object to states as after initialization.
 *
 * After each call to lxb_selectors_find() and lxb_selectors_find_for_node(),
 * the lxb_selectors_t object is cleared. That is, you don't need to call this
 * function every time after searching by a selector.
 *
 * @param[in] lxb_url_parser_t *
 */

/*
 * Destroy lxb_selectors_t object.
 *
 * Destroying all caches.
 *
 * @param[in] lxb_selectors_t *. Can be NULL.
 * @param[in] if false: only destroys internal caches.
 * if true: destroys the lxb_selectors_t object and all internal caches.
 *
 * @return lxb_selectors_t * if self_destroy = false, otherwise NULL.
 */

/*
 * Search for nodes by selector list.
 *
 * Default Behavior:
 *    1. The root node does not participate in the search, only its child nodes.
 *    2. If a node matches multiple selector lists, a callback with that node
 *       will be called on each list.
 *       For example:
 *           HTML: <div id="ok"><span></span></div>
 *           Selectors: div, div[id="ok"], div:has(:not(a))
 *       For each selector list, a callback with a "div" node will be called.
 *
 * To change the search behavior, see lxb_selectors_opt_set().
 *
 * @param[in] lxb_selectors_t *.
 * @param[in] lxb_dom_node_t *.  The node from which the search will begin.
 * @param[in] const lxb_css_selector_list_t *.  Selectors List.
 * @param[in] lxb_selectors_cb_f.  Callback for a found node.
 * @param[in] void *.  Context for the callback.
 * if true: destroys the lxb_selectors_t object and all internal caches.
 *
 * @return LXB_STATUS_OK if successful, otherwise an error status value.
 */

/*
 * Match a node to a Selectors List.
 *
 * In other words, the function checks which selector lists will find the
 * specified node.
 *
 * Default Behavior:
 *    1. If a node matches multiple selector lists, a callback with that node
 *       will be called on each list.
 *       For example:
 *           HTML: <div id="ok"><span></span></div>
 *           Node: div
 *           Selectors: div, div[id="ok"], div:has(:not(a))
 *       For each selector list, a callback with a "div" node will be called.
 *
 * To change the search behavior, see lxb_selectors_opt_set().
 *
 * @param[in] lxb_selectors_t *.
 * @param[in] lxb_dom_node_t *.  The node from which the search will begin.
 * @param[in] const lxb_css_selector_list_t *.  Selectors List.
 * @param[in] lxb_selectors_cb_f.  Callback for a found node.
 * @param[in] void *.  Context for the callback.
 * if true: destroys the lxb_selectors_t object and all internal caches.
 *
 * @return LXB_STATUS_OK if successful, otherwise an error status value.
 */

/*
 * Deprecated!
 * This function does exactly the same thing as lxb_selectors_match_node().
 */

/*
 * Inline functions.
 */

/*
 * The function sets the node search options.
 *
 * For more information, see lxb_selectors_opt_t.
 *
 * @param[in] lxb_selectors_t *.
 * @param[in] lxb_selectors_opt_t.
 */
 void lxb_selectors_opt_set(lxb_selectors_t* selectors, lxb_selectors_opt_t opt)
{
    selectors.options = opt;
}

/*
 * Get the current selector.
 *
 * Function to get the selector by which the node was found.
 * Use context (void *ctx) to pass the lxb_selectors_t object to the callback.
 *
 * @param[in] const lxb_selectors_t *.
 *
 * @return const lxb_css_selector_list_t *.
 */
 const(lxb_css_selector_list_t)* lxb_selectors_selector(const(lxb_selectors_t)* selectors)
{
    return selectors.current.entry.selector.list;
}

/*
 * Not inline for inline.
 */

/*
 * Same as lxb_selectors_opt_set() function, but not inline.
 */

/*
 * Same as lxb_selectors_selector() function, but not inline.
 */

// ---- selectors.c ----
/*
 * Copyright (C) 2021-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
























































lxb_selectors_t* lxb_selectors_create()
{
    return cast(lxb_selectors*) lexbor_calloc(1, lxb_selectors_t.sizeof);
}

lxb_status_t lxb_selectors_init(lxb_selectors_t* selectors)
{
    lxb_status_t status = void;

    if (selectors == null) {
        return LXB_STATUS_ERROR_INCOMPLETE_OBJECT;
    }

    selectors.objs = lexbor_dobject_create();
    status = lexbor_dobject_init(selectors.objs,
                                 128, lxb_selectors_entry_t.sizeof);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    selectors.nested = lexbor_dobject_create();
    status = lexbor_dobject_init(selectors.nested,
                                 64, lxb_selectors_nested_t.sizeof);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    selectors.options = LXB_SELECTORS_OPT_DEFAULT;

    return LXB_STATUS_OK;
}

void lxb_selectors_clean(lxb_selectors_t* selectors)
{
    lexbor_dobject_clean(selectors.objs);
    lexbor_dobject_clean(selectors.nested);
}

lxb_selectors_t* lxb_selectors_destroy(lxb_selectors_t* selectors, bool self_destroy)
{
    if (selectors == null) {
        return null;
    }

    selectors.objs = lexbor_dobject_destroy(selectors.objs, true);
    selectors.nested = lexbor_dobject_destroy(selectors.nested, true);

    if (self_destroy) {
        return cast(lxb_selectors*) lexbor_free(selectors);
    }

    return selectors;
}

private lxb_selectors_entry_t* lxb_selectors_state_entry_create(lxb_selectors_t* selectors, const(lxb_css_selector_t)* selector, lxb_selectors_entry_t* root, lxb_dom_node_t* node)
{
    lxb_selectors_entry_t* entry = void;
    lxb_css_selector_combinator_t combinator = void;

    combinator = selector.combinator;

    do {
        selector = selector.prev;

        entry = cast(lxb_selectors_entry*) lexbor_dobject_calloc(selectors.objs);
        if (entry == null) {
            selectors.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;
            return null;
        }

        entry.combinator = selector.combinator;
        entry.selector = selector;
        entry.node = node;

        if (root.prev != null) {
            root.prev.next = entry;
            entry.prev = root.prev;
        }

        entry.next = root;
        root.prev = entry;
    }
    while (selector.combinator == LXB_CSS_SELECTOR_COMBINATOR_CLOSE
           && selector.prev != null);

    entry.combinator = combinator;

    return entry;
}

private lxb_selectors_entry_t* lxb_selectors_state_entry_create_forward(lxb_selectors_t* selectors, const(lxb_css_selector_t)* selector, lxb_selectors_entry_t* root, lxb_dom_node_t* node)
{
    lxb_selectors_entry_t* entry = void;

    selector = selector.next;

    entry = cast(lxb_selectors_entry*) lexbor_dobject_calloc(selectors.objs);
    if (entry == null) {
        selectors.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        return null;
    }

    entry.combinator = selector.combinator;
    entry.selector = selector;
    entry.node = node;

    entry.prev = root;
    root.next = entry;

    return entry;
}

private lxb_selectors_entry_t* lxb_selectors_entry_make_first(lxb_selectors_t* selectors, lxb_css_selector_t* selector)
{
    lxb_selectors_entry_t* entry = void, prev = void;

    prev = null;

    do {
        entry = cast(lxb_selectors_entry*) lexbor_dobject_calloc(selectors.objs);
        if (entry == null) {
            return null;
        }

        entry.selector = selector;
        entry.combinator = LXB_CSS_SELECTOR_COMBINATOR_CLOSE;

        if (prev != null) {
            prev.next = entry;
            entry.prev = prev;
        }

        if (selector.combinator != LXB_CSS_SELECTOR_COMBINATOR_CLOSE
            || selector.prev == null)
        {
            break;
        }

        prev = entry;
        selector = selector.prev;
    }
    while (true);

    return entry;
}

 lxb_dom_node_t* lxb_selectors_descendant(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry, lxb_dom_node_t* node)
{
    node = node.parent;

    while (node != null) {
        if (node.type == LXB_DOM_NODE_TYPE_ELEMENT
            && lxb_selectors_match(selectors, entry, node))
        {
            return node;
        }

        node = node.parent;
    }

    return null;
}

 lxb_dom_node_t* lxb_selectors_descendant_forward(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry, lxb_dom_node_t* node)
{
    lxb_dom_node_t* root = void;
    lxb_selectors_nested_t* current = selectors.current;

    if (entry.prev != null) {
        root = entry.prev.node;
    }
    else {
        root = current.root;
    }

    do {
        if (node.first_child != null) {
            node = node.first_child;
        }
        else {

        next:

            while (node != root && node.next == null) {
                node = node.parent;
            }

            if (node == root) {
                break;
            }

            node = node.next;
        }

        if (node.type != LXB_DOM_NODE_TYPE_ELEMENT) {
            goto next;
        }

        if (lxb_selectors_match(selectors, entry, node)) {
            return node;
        }
    }
    while (node != null);

    return null;
}

 lxb_dom_node_t* lxb_selectors_close(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry, lxb_dom_node_t* node)
{
    if (lxb_selectors_match(selectors, entry, node)) {
        return node;
    }

    return null;
}

 lxb_dom_node_t* lxb_selectors_close_forward(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry, lxb_dom_node_t* node)
{
    if (lxb_selectors_match(selectors, entry, node)) {
        return node;
    }

    return null;
}

 lxb_dom_node_t* lxb_selectors_child(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry, lxb_dom_node_t* root)
{
    root = root.parent;

    if (root != null && root.type == LXB_DOM_NODE_TYPE_ELEMENT
        && lxb_selectors_match(selectors, entry, root))
    {
        return root;
    }

    return null;
}

 lxb_dom_node_t* lxb_selectors_child_forward(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry, lxb_dom_node_t* root)
{
    if (entry.prev != null) {
        if (entry.prev.node == root) {
            root = root.first_child;
        }
        else {
            root = root.next;
        }
    }
    else if (selectors.current.root == root) {
        root = root.first_child;
    }
    else {
        root = root.next;
    }

    while (root != null) {
        if (root.type == LXB_DOM_NODE_TYPE_ELEMENT
            && lxb_selectors_match(selectors, entry, root))
        {
            return root;
        }

        root = root.next;
    }

    return null;
}

 lxb_dom_node_t* lxb_selectors_sibling(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry, lxb_dom_node_t* node)
{
    node = node.prev;

    while (node != null) {
        if (node.type == LXB_DOM_NODE_TYPE_ELEMENT) {
            if (lxb_selectors_match(selectors, entry, node)) {
                return node;
            }

            return null;
        }

        node = node.prev;
    }

    return null;
}

 lxb_dom_node_t* lxb_selectors_sibling_forward(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry, lxb_dom_node_t* node)
{
    node = node.next;

    while (node != null) {
        if (node.type == LXB_DOM_NODE_TYPE_ELEMENT) {
            if (lxb_selectors_match(selectors, entry, node)) {
                return node;
            }

            return null;
        }

        node = node.next;
    }

    return null;
}

 lxb_dom_node_t* lxb_selectors_following(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry, lxb_dom_node_t* node)
{
    node = node.prev;

    while (node != null) {
        if (node.type == LXB_DOM_NODE_TYPE_ELEMENT &&
            lxb_selectors_match(selectors, entry, node))
        {
            return node;
        }

        node = node.prev;
    }

    return null;
}

 lxb_dom_node_t* lxb_selectors_following_forward(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry, lxb_dom_node_t* node)
{
    node = node.next;

    while (node != null) {
        if (node.type == LXB_DOM_NODE_TYPE_ELEMENT &&
            lxb_selectors_match(selectors, entry, node))
        {
            return node;
        }

        node = node.next;
    }

    return null;
}

 void lxb_selectors_switch_to_found_check(lxb_selectors_t* selectors, lxb_selectors_nested_t* current)
{
    if (current.forward) {
        selectors.state = &lxb_selectors_state_found_check_forward;
    }
    else {
        selectors.state = &lxb_selectors_state_found_check;
    }
}

 void lxb_selectors_switch_to_not_found(lxb_selectors_t* selectors, lxb_selectors_nested_t* current)
{
    if (current.forward) {
        selectors.state = &lxb_selectors_state_not_found_forward;
    }
    else {
        selectors.state = &lxb_selectors_state_not_found;
    }
}

private lxb_selectors_entry_t* lxb_selectors_state_failed(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    return null;
}

lxb_status_t lxb_selectors_find(lxb_selectors_t* selectors, lxb_dom_node_t* root, const(lxb_css_selector_list_t)* list, lxb_selectors_cb_f cb, void* ctx)
{
    lxb_selectors_entry_t* entry = void;
    lxb_selectors_nested_t nested = void;

    entry = lxb_selectors_entry_make_first(selectors, cast(lxb_css_selector*) list.last);
    if (entry == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    nested.parent = null;
    nested.entry = entry;
    nested.first = entry;
    nested.top = entry;
    nested.cb = cb;
    nested.ctx = ctx;
    nested.forward = false;

    selectors.current = &nested;
    selectors.status = LXB_STATUS_OK;

    return lxb_selectors_tree(selectors, root);
}

lxb_status_t lxb_selectors_match_node(lxb_selectors_t* selectors, lxb_dom_node_t* node, const(lxb_css_selector_list_t)* list, lxb_selectors_cb_f cb, void* ctx)
{
    lxb_status_t status = void;
    lxb_selectors_entry_t* entry = void;
    lxb_selectors_nested_t nested = void;

    if (node.type != LXB_DOM_NODE_TYPE_ELEMENT) {
        return LXB_STATUS_OK;
    }

    entry = lxb_selectors_entry_make_first(selectors, cast(lxb_css_selector*) list.last);
    if (entry == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    nested.parent = null;
    nested.entry = entry;
    nested.first = entry;
    nested.top = entry;
    nested.cb = cb;
    nested.ctx = ctx;
    nested.forward = false;

    selectors.current = &nested;
    selectors.status = LXB_STATUS_OK;

    status = lxb_selectors_run(selectors, node);

    lxb_selectors_clean(selectors);

    return status;
}

lxb_status_t lxb_selectors_find_reverse(lxb_selectors_t* selectors, lxb_dom_node_t* root, const(lxb_css_selector_list_t)* list, lxb_selectors_cb_f cb, void* ctx)
{
    return lxb_selectors_find(selectors, root, list, cb, ctx);
}

private lxb_status_t lxb_selectors_tree(lxb_selectors_t* selectors, lxb_dom_node_t* root)
{
    lxb_status_t status = void;
    lxb_dom_node_t* node = void;

    if (selectors.options & LXB_SELECTORS_OPT_MATCH_ROOT) {
        node = root;

        if (node.type == LXB_DOM_NODE_TYPE_DOCUMENT) {
            node = root.first_child;
        }
    }
    else {
        node = root.first_child;
    }

    if (node == null) {
        goto out_;
    }

    do {
        if (node.type != LXB_DOM_NODE_TYPE_ELEMENT) {
            goto next;
        }

        status = lxb_selectors_run(selectors, node);
        if (status != LXB_STATUS_OK) {
            if (status == LXB_STATUS_STOP) {
                break;
            }

            lxb_selectors_clean(selectors);

            return status;
        }

        if (node.first_child != null) {
            node = node.first_child;
        }
        else {

        next:

            while (node != root && node.next == null) {
                node = node.parent;
            }

            if (node == root) {
                break;
            }

            node = node.next;
        }
    }
    while (true);

out_:
    lxb_selectors_clean(selectors);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_selectors_run(lxb_selectors_t* selectors, lxb_dom_node_t* node)
{
    lxb_selectors_entry_t* entry = void;
    lxb_selectors_nested_t* current = selectors.current;

    entry = current.entry;

    entry.node = node;
    current.root = node;
    selectors.state = &lxb_selectors_state_find;

    do {
        entry = selectors.state(selectors, entry);
    }
    while (entry != null);

    current.first = current.top;
    current.entry = current.top;

    return selectors.status;
}

private lxb_selectors_entry_t* lxb_selectors_state_find(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    lxb_dom_node_t* node = void;

    selectors.state = &lxb_selectors_state_found_check;

    switch (entry.combinator) {
        case LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT:
            node = lxb_selectors_descendant(selectors, entry, entry.node);
            break;

        case LXB_CSS_SELECTOR_COMBINATOR_CLOSE:
            node = lxb_selectors_close(selectors, entry, entry.node);
            break;

        case LXB_CSS_SELECTOR_COMBINATOR_CHILD:
            node = lxb_selectors_child(selectors, entry, entry.node);
            break;

        case LXB_CSS_SELECTOR_COMBINATOR_SIBLING:
            node = lxb_selectors_sibling(selectors, entry, entry.node);
            break;

        case LXB_CSS_SELECTOR_COMBINATOR_FOLLOWING:
            node = lxb_selectors_following(selectors, entry, entry.node);
            break;

        case LXB_CSS_SELECTOR_COMBINATOR_CELL:
        default:
            selectors.status = LXB_STATUS_ERROR;
            return null;
    }

    if (node == null) {
        selectors.state = &lxb_selectors_state_not_found;
    }
    else {
        selectors.current.entry.node = node;
    }

    return selectors.current.entry;
}

private lxb_selectors_entry_t* lxb_selectors_state_find_forward(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    lxb_dom_node_t* node = void;

    selectors.state = &lxb_selectors_state_found_check_forward;

    switch (entry.combinator) {
        case LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT:
            node = lxb_selectors_descendant_forward(selectors, entry,
                                                    entry.node);
            break;

        case LXB_CSS_SELECTOR_COMBINATOR_CLOSE:
            node = lxb_selectors_close_forward(selectors, entry,
                                               entry.node);
            break;

        case LXB_CSS_SELECTOR_COMBINATOR_CHILD:
            node = lxb_selectors_child_forward(selectors, entry, entry.node);
            break;

        case LXB_CSS_SELECTOR_COMBINATOR_SIBLING:
            node = lxb_selectors_sibling_forward(selectors, entry, entry.node);
            break;

        case LXB_CSS_SELECTOR_COMBINATOR_FOLLOWING:
            node = lxb_selectors_following_forward(selectors, entry,
                                                   entry.node);
            break;

        case LXB_CSS_SELECTOR_COMBINATOR_CELL:
        default:
            selectors.status = LXB_STATUS_ERROR;
            return null;
    }

    if (node == null) {
    try_next:

        do {
            if (entry.prev == null) {
                return lxb_selectors_next_list_forward(selectors, entry);
            }

            entry = entry.prev;
        }
        while (entry.combinator == LXB_CSS_SELECTOR_COMBINATOR_CLOSE);

        if (entry.combinator == LXB_CSS_SELECTOR_COMBINATOR_SIBLING) {
            goto try_next;
        }

        selectors.current.entry = entry;
        selectors.state = &lxb_selectors_state_find_forward;
    }
    else {
        selectors.current.entry.node = node;
    }

    return selectors.current.entry;
}

 lxb_selectors_entry_t* lxb_selectors_done(lxb_selectors_t* selectors)
{
    lxb_selectors_nested_t* current = selectors.current;

    if (current.parent == null) {
        return null;
    }

    selectors.current = current.parent;

    return selectors.current.entry;
}

 lxb_selectors_entry_t* lxb_selectors_exit(lxb_selectors_t* selectors)
{
    lxb_selectors_nested_t* current = selectors.current;

    if (current.parent == null) {
        return null;
    }

    selectors.state = current.return_state;

    return current.entry;
}

private lxb_selectors_entry_t* lxb_selectors_state_found_check(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    lxb_selectors_nested_t* current = void;
    lxb_dom_node_t* node = void;
    lxb_selectors_entry_t* prev = void;
    const(lxb_css_selector_t)* selector = void;

    current = selectors.current;
    entry = current.entry;
    node = entry.node;

    if (entry.prev == null) {
        selector = entry.selector;

        while (selector.combinator == LXB_CSS_SELECTOR_COMBINATOR_CLOSE
               && selector.prev != null)
        {
            selector = selector.prev;
        }

        if (selector.prev == null) {
            return lxb_selectors_state_found(selectors, entry);
        }

        prev = lxb_selectors_state_entry_create(selectors, selector,
                                                entry, node);
        current.entry = prev;
        selectors.state = &lxb_selectors_state_find;

        return prev;
    }

    selectors.state = &lxb_selectors_state_find;

    current.entry = entry.prev;
    entry.prev.node = node;

    return entry.prev;
}

private lxb_selectors_entry_t* lxb_selectors_state_found_check_forward(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    lxb_selectors_nested_t* current = void;
    lxb_dom_node_t* node = void;
    lxb_selectors_entry_t* next = void;
    const(lxb_css_selector_t)* selector = void;

    current = selectors.current;
    entry = current.entry;
    node = entry.node;

    if (entry.next == null) {
        selector = entry.selector;

        if (selector.next == null) {
            return lxb_selectors_state_found_forward(selectors, entry);
        }

        next = lxb_selectors_state_entry_create_forward(selectors, selector,
                                                        entry, node);
        current.entry = next;
        selectors.state = &lxb_selectors_state_find_forward;

        return next;
    }

    selectors.state = &lxb_selectors_state_find_forward;

    current.entry = entry.next;
    entry.next.node = node;

    return entry.next;
}

private lxb_selectors_entry_t* lxb_selectors_state_found(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    lxb_selectors_nested_t* current = void;
    const(lxb_css_selector_t)* selector = void;

    current = selectors.current;
    selector = current.entry.selector;

    selectors.state = &lxb_selectors_state_find;

    selectors.status = current.cb(current.root,
                                    selector.list.specificity,
                                    current.ctx);

    if ((selectors.options & LXB_SELECTORS_OPT_MATCH_FIRST) == 0
        && current.parent == null)
    {
        if (selectors.status == LXB_STATUS_OK) {
            entry = selectors.current.first;
            return lxb_selectors_next_list(selectors, entry);
        }
    }

    return lxb_selectors_done(selectors);
}

private lxb_selectors_entry_t* lxb_selectors_state_found_forward(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    lxb_selectors_nested_t* current = void;
    const(lxb_css_selector_t)* selector = void;

    current = selectors.current;
    selector = current.entry.selector;

    selectors.state = &lxb_selectors_state_find_forward;

    selectors.status = current.cb(current.root,
                                    selector.list.specificity,
                                    current.ctx);

    if ((selectors.options & LXB_SELECTORS_OPT_MATCH_FIRST) == 0
        && current.parent == null)
    {
        if (selectors.status == LXB_STATUS_OK) {
            entry = selectors.current.first;
            return lxb_selectors_next_list_forward(selectors, entry);
        }
    }

    return lxb_selectors_done(selectors);
}

private lxb_selectors_entry_t* lxb_selectors_state_not_found(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    lxb_selectors_nested_t* current = void;

    current = selectors.current;
    entry = current.entry;

try_next:

    if (entry.next == null) {
        return lxb_selectors_next_list(selectors, entry);
    }

    entry = entry.next;

    while (entry.combinator == LXB_CSS_SELECTOR_COMBINATOR_CLOSE) {
        if (entry.next == null) {
            goto try_next;
        }

        entry = entry.next;
    }

    switch (entry.combinator) {
        case LXB_CSS_SELECTOR_COMBINATOR_SIBLING:
        case LXB_CSS_SELECTOR_COMBINATOR_CHILD:
        case LXB_CSS_SELECTOR_COMBINATOR_CLOSE:
            goto try_next;

        default:
            break;
    }

    current.entry = entry;
    selectors.state = &lxb_selectors_state_find;

    return entry;
}

private lxb_selectors_entry_t* lxb_selectors_state_not_found_forward(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
try_next:

    if (entry.prev == null) {
        return lxb_selectors_next_list_forward(selectors, entry);
    }

    while (entry.combinator == LXB_CSS_SELECTOR_COMBINATOR_CLOSE) {
        if (entry.prev == null) {
            goto try_next;
        }

        entry = entry.prev;
    }

    if (entry.combinator == LXB_CSS_SELECTOR_COMBINATOR_SIBLING) {
        if (entry.prev != null) {
            entry = entry.prev;
        }

        goto try_next;
    }

    selectors.current.entry = entry;
    selectors.state = &lxb_selectors_state_find_forward;

    return entry;
}

private lxb_selectors_entry_t* lxb_selectors_next_list(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    if (entry.selector.list.next == null) {
        return lxb_selectors_exit(selectors);
    }

    selectors.state = &lxb_selectors_state_find;

    /*
     * Try the following selectors from the selector list.
     */

    return lxb_selectors_make_following(selectors, entry);
}

private lxb_selectors_entry_t* lxb_selectors_next_list_forward(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    if (entry.selector.list.next == null) {
        return lxb_selectors_exit(selectors);
    }

    selectors.state = &lxb_selectors_state_find_forward;

    /*
     * Try the following selectors from the selector list.
     */

    return lxb_selectors_make_following_forward(selectors, entry);
}

private lxb_selectors_entry_t* lxb_selectors_make_following(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    lxb_selectors_entry_t* next = void;
    lxb_selectors_nested_t* current = void;
    const(lxb_css_selector_t)* selector = void;

    selector = entry.selector;
    current = selectors.current;

    if (entry.following != null) {
        entry.following.node = current.root;
        current.first = entry.following;
        current.entry = entry.following;

        return entry.following;
    }

    next = lxb_selectors_entry_make_first(selectors,
                                          cast(lxb_css_selector_t*) selector.list.next.last);
    if (next == null) {
        selectors.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        return null;
    }

    next.node = current.root;

    entry.following = next;
    current.first = next;
    current.entry = next;

    return next;
}

private lxb_selectors_entry_t* lxb_selectors_make_following_forward(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    lxb_selectors_entry_t* next = void;
    lxb_selectors_nested_t* current = void;
    const(lxb_css_selector_t)* selector = void;

    selector = entry.selector;
    current = selectors.current;

    if (entry.following != null) {
        entry.following.node = current.root;
        current.first = entry.following;
        current.entry = entry.following;

        return entry.following;
    }

    next = cast(lxb_selectors_entry*) lexbor_dobject_calloc(selectors.objs);
    if (next == null) {
        selectors.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        return null;
    }

    next.selector = selector.list.next.first;
    next.node = current.root;
    next.combinator = next.selector.combinator;

    entry.following = next;
    current.first = next;
    current.entry = next;

    return next;
}

private lxb_selectors_entry_t* lxb_selectors_state_after_find(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    selectors.current = selectors.current.parent;

    lxb_selectors_switch_to_not_found(selectors, selectors.current);

    return selectors.current.entry;
}

private lxb_selectors_entry_t* lxb_selectors_state_after_not(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    selectors.current = selectors.current.parent;

    lxb_selectors_switch_to_found_check(selectors, selectors.current);

    return selectors.current.entry;
}

 lxb_dom_node_t* lxb_selectors_state_nth_child_node(const(lxb_css_selector_pseudo_t)* pseudo, lxb_dom_node_t* node)
{
    if (pseudo.type == LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_CHILD) {
        node = node.prev;

        while (node != null) {
            if (node.type == LXB_DOM_NODE_TYPE_ELEMENT) {
                break;
            }

            node = node.prev;
        }
    }
    else {
        node = node.next;

        while (node != null) {
            if (node.type == LXB_DOM_NODE_TYPE_ELEMENT) {
                break;
            }

            node = node.next;
        }
    }

    return node;
}

 lxb_selectors_entry_t* lxb_selectors_state_nth_child_done(lxb_selectors_t* selectors, const(lxb_css_selector_pseudo_t)* pseudo, size_t index)
{
    if (lxb_selectors_anb_calc(cast(lxb_css_selector_anb_of_t*) pseudo.data, index)) {
        lxb_selectors_switch_to_found_check(selectors, selectors.current);
    }
    else {
        lxb_selectors_switch_to_not_found(selectors, selectors.current);
    }

    return selectors.current.entry;
}

private lxb_selectors_entry_t* lxb_selectors_state_after_nth_child(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    lxb_dom_node_t* node = void;
    lxb_selectors_nested_t* current = void;
    const(lxb_css_selector_pseudo_t)* pseudo = void;

    current = selectors.current;

    if (current.index == 0) {
        selectors.state = &lxb_selectors_state_not_found;
        selectors.current = selectors.current.parent;

        return selectors.current.entry;
    }

    pseudo = &current.parent.entry.selector.u.pseudo;
    node = lxb_selectors_state_nth_child_node(pseudo, current.root);

    if (node == null) {
        selectors.current = selectors.current.parent;

        return lxb_selectors_state_nth_child_done(selectors, pseudo,
                                                  current.index);
    }

    current.root = node;
    current.entry.node = node;

    selectors.state = &lxb_selectors_state_find;

    return entry;
}

private lxb_selectors_entry_t* lxb_selectors_state_nth_child_found(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry)
{
    lxb_dom_node_t* node = void;
    lxb_selectors_nested_t* current = void;
    const(lxb_css_selector_pseudo_t)* pseudo = void;

    current = entry.nested;
    pseudo = &entry.selector.u.pseudo;
    node = lxb_selectors_state_nth_child_node(pseudo, current.root);

    if (node == null) {
        return lxb_selectors_state_nth_child_done(selectors, pseudo,
                                                  current.index);
    }

    current.root = node;
    current.entry.node = node;

    selectors.current = current;
    selectors.state = &lxb_selectors_state_find;

    return current.entry;
}

private bool lxb_selectors_match(lxb_selectors_t* selectors, lxb_selectors_entry_t* entry, lxb_dom_node_t* node)
{
    lxb_dom_element_t* element = void;

    switch (entry.selector.type) {
        case LXB_CSS_SELECTOR_TYPE_ANY:
            return true;

        case LXB_CSS_SELECTOR_TYPE_ELEMENT:
            return lxb_selectors_match_element(entry.selector, node, entry);

        case LXB_CSS_SELECTOR_TYPE_ID:
            return lxb_selectors_match_id(entry.selector, node);

        case LXB_CSS_SELECTOR_TYPE_CLASS:
            element = (cast(lxb_dom_element_t*) (node));

            if (element.attr_class == null
                || element.attr_class.value == null)
            {
                return false;
            }

            return lxb_selectors_match_class(element.attr_class.value,
                                             &entry.selector.name, true);

        case LXB_CSS_SELECTOR_TYPE_ATTRIBUTE:
            return lxb_selectors_match_attribute(entry.selector, node, entry);

        case LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS:
            return lxb_selectors_pseudo_class(entry.selector, node);

        case LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS_FUNCTION:
            return lxb_selectors_pseudo_class_function(selectors,
                                                       entry.selector, node);
        case LXB_CSS_SELECTOR_TYPE_PSEUDO_ELEMENT:
            return lxb_selectors_pseudo_element(entry.selector, node);

        case LXB_CSS_SELECTOR_TYPE_PSEUDO_ELEMENT_FUNCTION:
            return false;

        default:
            break;
    }

    return false;
}

private bool lxb_selectors_match_element(const(lxb_css_selector_t)* selector, lxb_dom_node_t* node, lxb_selectors_entry_t* entry)
{
    lxb_tag_id_t tag_id = void;

    if (entry.id == 0) {
        tag_id = lxb_tag_id_by_name(node.owner_document.tags,
                                    selector.name.data, selector.name.length);
        if (tag_id == LXB_TAG__UNDEF) {
            return false;
        }

        entry.id = tag_id;
    }

    return node.local_name == entry.id;
}

private bool lxb_selectors_match_id(const(lxb_css_selector_t)* selector, lxb_dom_node_t* node)
{
    const(lexbor_str_t)* trg = void, src = void;
    lxb_dom_element_t* element = void;

    element = (cast(lxb_dom_element_t*) (node));

    if (element.attr_id == null || element.attr_id.value == null) {
        return false;
    }

    trg = element.attr_id.value;
    src = &selector.name;

    return trg.length == src.length
           && lexbor_str_data_ncasecmp(trg.data, src.data, src.length);
}

private bool lxb_selectors_match_class(const(lexbor_str_t)* target, const(lexbor_str_t)* src, bool quirks)
{
    lxb_char_t chr = void;

    if (target.length < src.length) {
        return false;
    }

    bool is_it = false;

    const(lxb_char_t)* data = target.data;
    const(lxb_char_t)* pos = data;
    const(lxb_char_t)* end = data + target.length;

    for (; data < end; data++) {
        chr = *data;

        if ((chr == ' ' || chr == '\t' || chr == '\n' || chr == '\f' || chr == '\r')) {

            if (cast(size_t) (data - pos) == src.length) {
                if (quirks) {
                    is_it = lexbor_str_data_ncasecmp(pos, src.data, src.length);
                }
                else {
                    is_it = lexbor_str_data_ncmp(pos, src.data, src.length);
                }

                if (is_it) {
                    return true;
                }
            }

            if (cast(size_t) (end - data) < src.length) {
                return false;
            }

            pos = data + 1;
        }
    }

    if (cast(size_t) (end - pos) == src.length && src.length != 0) {
        if (quirks) {
            is_it = lexbor_str_data_ncasecmp(pos, src.data, src.length);
        }
        else {
            is_it = lexbor_str_data_ncmp(pos, src.data, src.length);
        }
    }

    return is_it;
}

private bool lxb_selectors_match_attribute(const(lxb_css_selector_t)* selector, lxb_dom_node_t* node, lxb_selectors_entry_t* entry)
{
    bool res = void, ins = void;
    lxb_dom_attr_t* dom_attr = void;
    lxb_dom_element_t* element = void;
    const(lexbor_str_t)* trg = void, src = void;
    const(lxb_dom_attr_data_t)* attr_data = void;
    const(lxb_css_selector_attribute_t)* attr = void;

    static const(lexbor_str_t) lxb_blank_str = {
        data: cast(lxb_char_t*) "",
        length: 0
    };

    element = (cast(lxb_dom_element_t*) (node));
    attr = &selector.u.attribute;

    if (entry.id == 0) {
        attr_data = lxb_dom_attr_data_by_local_name(node.owner_document.attrs,
                                    selector.name.data, selector.name.length);
        if (attr_data == null) {
            return false;
        }

        entry.id = attr_data.attr_id;
    }

    dom_attr = lxb_dom_element_attr_by_id(element, entry.id);
    if (dom_attr == null) {
        return false;
    }

    trg = dom_attr.value;
    src = &attr.value;

    if (src.data == null) {
        return true;
    }

    if (trg == null) {
        trg = &lxb_blank_str;
    }

    ins = attr.modifier == LXB_CSS_SELECTOR_MODIFIER_I;

    switch (attr.match) {
        case LXB_CSS_SELECTOR_MATCH_EQUAL: /*  = */
            if (trg.length == src.length) {
                if (ins) {
                    return lexbor_str_data_ncasecmp(trg.data, src.data,
                                                    src.length);
                }

                return lexbor_str_data_ncmp(trg.data, src.data,
                                            src.length);
            }

            return false;

        case LXB_CSS_SELECTOR_MATCH_INCLUDE: /* ~= */
            return lxb_selectors_match_class(trg, src, ins);

        case LXB_CSS_SELECTOR_MATCH_DASH: /* |= */
            if (trg.length == src.length) {
                if (ins) {
                    return lexbor_str_data_ncasecmp(trg.data, src.data,
                                                    src.length);
                }

                return lexbor_str_data_ncmp(trg.data, src.data,
                                            src.length);
            }

            if (trg.length > src.length) {
                if (ins) {
                    res = lexbor_str_data_ncasecmp(trg.data,
                                                   src.data, src.length);
                }
                else {
                    res = lexbor_str_data_ncmp(trg.data,
                                               src.data, src.length);
                }

                if (res && trg.data[src.length] == '-') {
                    return true;
                }
            }

            return false;

        case LXB_CSS_SELECTOR_MATCH_PREFIX: /* ^= */
            if (src.length != 0 && trg.length >= src.length) {
                if (ins) {
                    return lexbor_str_data_ncasecmp(trg.data, src.data,
                                                    src.length);
                }

                return lexbor_str_data_ncmp(trg.data, src.data,
                                            src.length);
            }

            return false;

        case LXB_CSS_SELECTOR_MATCH_SUFFIX: /* $= */
            if (src.length != 0 && trg.length >= src.length) {
                size_t dif = trg.length - src.length;

                if (ins) {
                    return lexbor_str_data_ncasecmp(trg.data + dif,
                                                    src.data, src.length);
                }

                return lexbor_str_data_ncmp(trg.data + dif, src.data,
                                            src.length);
            }

            return false;

        case LXB_CSS_SELECTOR_MATCH_SUBSTRING: /* *= */
            if (src.length == 0) {
                return false;
            }

            if (ins) {
                return lexbor_str_data_ncasecmp_contain(trg.data, trg.length,
                                                        src.data, src.length);
            }

            return lexbor_str_data_ncmp_contain(trg.data, trg.length,
                                                src.data, src.length);
        default:
            break;
    }

    return false;
}

private bool lxb_selectors_pseudo_class(const(lxb_css_selector_t)* selector, const(lxb_dom_node_t)* node)
{
    lexbor_str_t* str = void;
    lxb_dom_attr_t* attr = void;
    const(lxb_dom_node_t)* root = void;
    const(lxb_css_selector_pseudo_t)* pseudo = &selector.u.pseudo;

    static const(lxb_char_t)[9] checkbox = lexbor_carray!"checkbox";
    static const(size_t) checkbox_length = checkbox.sizeof / lxb_char_t.sizeof - 1;

    static const(lxb_char_t)[6] radio = lexbor_carray!"radio";
    static const(size_t) radio_length = radio.sizeof / lxb_char_t.sizeof - 1;

    switch (pseudo.type) {
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_ACTIVE:
            attr = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (node)),
                                              LXB_DOM_ATTR_ACTIVE);
            return attr != null;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_ANY_LINK:
            if(node.local_name == LXB_TAG_A ||
               node.local_name == LXB_TAG_AREA ||
               node.local_name == LXB_TAG_MAP)
            {
                attr = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (node)),
                                                  LXB_DOM_ATTR_HREF);
                return attr != null;
            }

            return false;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_BLANK:
            return lxb_dom_node_is_empty(node);

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_CHECKED:
            if (node.local_name == LXB_TAG_INPUT) {
                attr = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (node)),
                                                  LXB_DOM_ATTR_TYPE);
                if (attr == null) {
                    return false;
                }

                if (attr.value == null) {
                    return false;
                }

                str = attr.value;

                if(str.length == 8) {
                    if (lexbor_str_data_ncasecmp(checkbox.ptr, str.data, checkbox_length)) {
                        goto check;
                    }
                }
                else if(str.length == 5) {
                    if (lexbor_str_data_ncasecmp(radio.ptr, str.data, radio_length)) {
                        goto check;
                    }
                }
            }
            else if(node.local_name == LXB_TAG_OPTION) {
                attr = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (node)),
                                                  LXB_DOM_ATTR_SELECTED);
                if (attr != null) {
                    return true;
                }
            }
            else if(node.local_name >= LXB_TAG__LAST_ENTRY) {
                goto check;
            }

            return false;

        check:

            attr = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (node)),
                                              LXB_DOM_ATTR_CHECKED);
            if (attr != null) {
                return true;
            }

            return false;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_CURRENT:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_DEFAULT:
            return false;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_DISABLED:
            return lxb_selectors_pseudo_class_disabled(node);

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_EMPTY:
            root = node;
            node = node.first_child;

            while (node != null) {
                if (node.local_name != LXB_TAG__EM_COMMENT) {
                    return false;
                }

                if (node.first_child != null) {
                    node = node.first_child;
                }
                else {
                    while (node != root && node.next == null) {
                        node = node.parent;
                    }

                    if (node == root) {
                        break;
                    }

                    node = node.next;
                }
            }

            return true;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_ENABLED:
            return !lxb_selectors_pseudo_class_disabled(node);

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FIRST_CHILD:
            return lxb_selectors_pseudo_class_first_child(node);

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FIRST_OF_TYPE:
            return lxb_selectors_pseudo_class_first_of_type(node);

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FOCUS:
            attr = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (node)),
                                              LXB_DOM_ATTR_FOCUS);
            return attr != null;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FOCUS_VISIBLE:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FOCUS_WITHIN:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FULLSCREEN:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUTURE:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_HOVER:
            attr = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (node)),
                                              LXB_DOM_ATTR_HOVER);
            return attr != null;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_IN_RANGE:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_INDETERMINATE:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_INVALID:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_LAST_CHILD:
            return lxb_selectors_pseudo_class_last_child(node);

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_LAST_OF_TYPE:
            return lxb_selectors_pseudo_class_last_of_type(node);

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_LINK:
            if (node.local_name == LXB_TAG_A
                || node.local_name == LXB_TAG_AREA
                || node.local_name == LXB_TAG_LINK)
            {
                attr = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (node)),
                                                  LXB_DOM_ATTR_HREF);
                return attr != null;
            }

            return false;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_LOCAL_LINK:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_ONLY_CHILD:
            return lxb_selectors_pseudo_class_first_child(node)
            && lxb_selectors_pseudo_class_last_child(node);

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_ONLY_OF_TYPE:
            return lxb_selectors_pseudo_class_first_of_type(node)
            && lxb_selectors_pseudo_class_last_of_type(node);

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_OPTIONAL:
            if (node.local_name == LXB_TAG_INPUT
                || node.local_name == LXB_TAG_SELECT
                || node.local_name == LXB_TAG_TEXTAREA)
            {
                attr = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (node)),
                                                  LXB_DOM_ATTR_REQUIRED);
                return attr == null;
            }

            return false;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_OUT_OF_RANGE:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_PAST:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_PLACEHOLDER_SHOWN:
            if (node.local_name == LXB_TAG_INPUT
                || node.local_name == LXB_TAG_TEXTAREA)
            {
                attr = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (node)),
                                                  LXB_DOM_ATTR_PLACEHOLDER);
                return attr != null;
            }

            return false;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_READ_ONLY:
            return !lxb_selectors_pseudo_class_read_write(node);

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_READ_WRITE:
            return lxb_selectors_pseudo_class_read_write(node);

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_REQUIRED:
            if (node.local_name == LXB_TAG_INPUT
                || node.local_name == LXB_TAG_SELECT
                || node.local_name == LXB_TAG_TEXTAREA)
            {
                attr = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (node)),
                                                  LXB_DOM_ATTR_REQUIRED);
                return attr != null;
            }

            return false;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_ROOT:
            return lxb_dom_document_root(cast(lxb_dom_document*) node.owner_document) == node;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_SCOPE:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_TARGET:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_TARGET_WITHIN:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_USER_INVALID:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_VALID:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_VISITED:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_WARNING:
            break;
    default: break;}

    return false;
}

private lxb_selectors_nested_t* lxb_selectors_nested_make(lxb_selectors_t* selectors, lxb_dom_node_t* node, lxb_css_selector_t* selector, bool forward)
{
    lxb_selectors_entry_t* next = void;
    lxb_selectors_entry_t* entry = void;

    entry = selectors.current.entry;
    entry.node = node;

    if (entry.nested == null) {
        if (!forward) {
            next = lxb_selectors_entry_make_first(selectors, selector);
            if (next == null) {
                selectors.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;
                return null;
            }
        }
        else {
            next = cast(lxb_selectors_entry*) lexbor_dobject_calloc(selectors.objs);
            if (next == null) {
                selectors.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;
                return null;
            }

            next.combinator = selector.combinator;
            next.selector = selector;
        }

        entry.nested = cast(lxb_selectors_nested*) lexbor_dobject_calloc(selectors.nested);
        if (entry.nested == null) {
            selectors.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;
            return null;
        }

        entry.nested.top = next;
        entry.nested.parent = selectors.current;
        entry.nested.forward = forward;
    }

    selectors.current = entry.nested;
    entry.nested.entry = entry.nested.top;
    entry.nested.first = entry.nested.top;

    selectors.current.root = node;
    selectors.current.ctx = selectors;

    return selectors.current;
}

private bool lxb_selectors_pseudo_class_function(lxb_selectors_t* selectors, const(lxb_css_selector_t)* selector, lxb_dom_node_t* node)
{
    size_t index = void;
    lxb_dom_node_t* base = void;
    lxb_selectors_nested_t* current = void;
    const(lxb_css_selector_list_t)* list = void;
    const(lxb_css_selector_anb_of_t)* anb = void;
    const(lxb_css_selector_pseudo_t)* pseudo = void;

    pseudo = &selector.u.pseudo;

    switch (pseudo.type) {
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_HAS:
            list = cast(const(lxb_css_selector_list_t)*) (cast(lxb_css_selector_list_t*) pseudo.data);

            current = lxb_selectors_nested_make(selectors, node,
                                                cast(lxb_css_selector*) list.first, true);
            if (current == null) {
                goto failed;
            }

            current.cb = &lxb_selectors_cb_ok;
            current.return_state = &lxb_selectors_state_after_find;
            selectors.state = &lxb_selectors_state_find_forward;

            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_CURRENT:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_IS:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_WHERE:
            list = cast(const(lxb_css_selector_list_t)*) (cast(lxb_css_selector_list_t*) pseudo.data);

            current = lxb_selectors_nested_make(selectors, node, cast(lxb_css_selector*) list.last,
                                                false);
            if (current == null) {
                goto failed;
            }

            current.cb = &lxb_selectors_cb_ok;
            current.return_state = &lxb_selectors_state_after_find;
            selectors.state = &lxb_selectors_state_find;

            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NOT:
            list = cast(const(lxb_css_selector_list_t)*) (cast(lxb_css_selector_list_t*) pseudo.data);

            current = lxb_selectors_nested_make(selectors, node, cast(lxb_css_selector*) list.last,
                                                false);
            if (current == null) {
                goto failed;
            }

            current.cb = &lxb_selectors_cb_not;
            current.return_state = &lxb_selectors_state_after_not;
            selectors.state = &lxb_selectors_state_find;

            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_CHILD:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_LAST_CHILD:
            anb = cast(const(lxb_css_selector_anb_of_t)*) pseudo.data;

            if (anb.of != null) {
                current = lxb_selectors_nested_make(selectors, node,
                                                    cast(lxb_css_selector_t*) anb.of.last, false);
                if (current == null) {
                    goto failed;
                }

                current.return_state = &lxb_selectors_state_after_nth_child;
                current.cb = &lxb_selectors_cb_nth_ok;
                current.index = 0;
                selectors.state = &lxb_selectors_state_find;

                return true;
            }

            index = 0;

            if (pseudo.type == LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_CHILD) {
                while (node != null) {
                    if (node.local_name != LXB_TAG__TEXT
                        && node.local_name != LXB_TAG__EM_COMMENT)
                    {
                        index++;
                    }

                    node = node.prev;
                }
            }
            else {
                while (node != null) {
                    if (node.local_name != LXB_TAG__TEXT
                        && node.local_name != LXB_TAG__EM_COMMENT)
                    {
                        index++;
                    }

                    node = node.next;
                }
            }

            return lxb_selectors_anb_calc(cast(lxb_css_selector_anb_of_t*) pseudo.data, index);

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_OF_TYPE:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_LAST_OF_TYPE:
            index = 0;
            base = node;

            if (pseudo.type == LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_OF_TYPE) {
                while (node != null) {
                    if(node.local_name == base.local_name
                       && node.ns == base.ns)
                    {
                        index++;
                    }

                    node = node.prev;
                }
            }
            else {
                while (node != null) {
                    if(node.local_name == base.local_name
                       && node.ns == base.ns)
                    {
                        index++;
                    }

                    node = node.next;
                }
            }

            return lxb_selectors_anb_calc(cast(lxb_css_selector_anb_of_t*) pseudo.data, index);

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_DIR:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_LANG:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_COL:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_LAST_COL:
        default:
            return false;
    }

    return true;

failed:

    selectors.state = &lxb_selectors_state_failed;
    selectors.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;

    return true;
}

private bool lxb_selectors_pseudo_element(const(lxb_css_selector_t)* selector, const(lxb_dom_node_t)* node)
{
    const(lxb_css_selector_pseudo_t)* pseudo = &selector.u.pseudo;

    switch (pseudo.type) {
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_AFTER:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_BACKDROP:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_BEFORE:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_FIRST_LETTER:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_FIRST_LINE:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_GRAMMAR_ERROR:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_INACTIVE_SELECTION:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_MARKER:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_PLACEHOLDER:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_SELECTION:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_SPELLING_ERROR:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_TARGET_TEXT:
            break;
    default: break;}

    return false;
}

private bool lxb_selectors_pseudo_class_disabled(const(lxb_dom_node_t)* node)
{
    lxb_dom_attr_t* attr = void;
    uintptr_t tag_id = node.local_name;

    attr = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (node)),
                                      LXB_DOM_ATTR_DISABLED);
    if (attr == null) {
        return false;
    }

    if (tag_id == LXB_TAG_BUTTON || tag_id == LXB_TAG_INPUT ||
        tag_id == LXB_TAG_SELECT || tag_id == LXB_TAG_TEXTAREA ||
        tag_id >= LXB_TAG__LAST_ENTRY)
    {
        return true;
    }

    node = node.parent;

    while (node != null) {
        if (node.local_name == LXB_TAG_FIELDSET
            && node.first_child.local_name != LXB_TAG_LEGEND)
        {
            return true;
        }

        node = node.parent;
    }

    return false;
}

private bool lxb_selectors_pseudo_class_first_child(const(lxb_dom_node_t)* node)
{
    node = node.prev;

    while (node != null) {
        if (node.local_name != LXB_TAG__TEXT
            && node.local_name != LXB_TAG__EM_COMMENT)
        {
            return false;
        }

        node = node.prev;
    }

    return true;
}

private bool lxb_selectors_pseudo_class_first_of_type(const(lxb_dom_node_t)* node)
{
    const(lxb_dom_node_t)* root = node;
    node = node.prev;

    while (node) {
        if (node.local_name == root.local_name
            && node.ns == root.ns)
        {
            return false;
        }

        node = node.prev;
    }

    return true;
}

private bool lxb_selectors_pseudo_class_last_child(const(lxb_dom_node_t)* node)
{
    node = node.next;

    while (node != null) {
        if (node.local_name != LXB_TAG__TEXT
            && node.local_name != LXB_TAG__EM_COMMENT)
        {
            return false;
        }

        node = node.next;
    }

    return true;
}

private bool lxb_selectors_pseudo_class_last_of_type(const(lxb_dom_node_t)* node)
{
    const(lxb_dom_node_t)* root = node;
    node = node.next;

    while (node) {
        if (node.local_name == root.local_name
            && node.ns == root.ns)
        {
            return false;
        }

        node = node.next;
    }

    return true;
}

private bool lxb_selectors_pseudo_class_read_write(const(lxb_dom_node_t)* node)
{
    lxb_dom_attr_t* attr = void;

    if (node.local_name == LXB_TAG_INPUT
        || node.local_name == LXB_TAG_TEXTAREA)
    {
        attr = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (node)),
                                          LXB_DOM_ATTR_READONLY);
        if (attr != null) {
            return false;
        }

        return !lxb_selectors_pseudo_class_disabled(node);
    }

    return false;
}

private bool lxb_selectors_anb_calc(lxb_css_selector_anb_of_t* anb, size_t index)
{
    double num = void;

    if (anb.anb.a == 0) {
        if (anb.anb.b >= 0 && cast(size_t) anb.anb.b == index) {
            return true;
        }
    }
    else {
        num = (cast(double) index - cast(double) anb.anb.b) / cast(double) anb.anb.a;

        if (num >= 0.0f && (num - trunc(num)) == 0.0f) {
            return true;
        }
    }

    return false;
}

private lxb_status_t lxb_selectors_cb_ok(lxb_dom_node_t* node, lxb_css_selector_specificity_t spec, void* ctx)
{
    lxb_selectors_t* selectors = cast(lxb_selectors*) ctx;

    lxb_selectors_switch_to_found_check(selectors, selectors.current.parent);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_selectors_cb_not(lxb_dom_node_t* node, lxb_css_selector_specificity_t spec, void* ctx)
{
    lxb_selectors_t* selectors = cast(lxb_selectors*) ctx;

    lxb_selectors_switch_to_not_found(selectors, selectors.current.parent);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_selectors_cb_nth_ok(lxb_dom_node_t* node, lxb_css_selector_specificity_t spec, void* ctx)
{
    lxb_selectors_t* selectors = cast(lxb_selectors*) ctx;

    selectors.current.index += 1;
    selectors.state = &lxb_selectors_state_nth_child_found;

    return LXB_STATUS_OK;
}

void lxb_selectors_opt_set_noi(lxb_selectors_t* selectors, lxb_selectors_opt_t opt)
{
    lxb_selectors_opt_set(selectors, opt);
}

const(lxb_css_selector_list_t)* lxb_selectors_selector_noi(const(lxb_selectors_t)* selectors)
{
    return lxb_selectors_selector(selectors);
}
