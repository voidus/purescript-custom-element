"use strict";

exports.define_ = name => observedAttributes => spec => () => {
    class Element extends HTMLElement {
        static get observedAttributes() { return observedAttributes };
        //TODO reflected properties
        constructor() {
            super();
            // TODO allow shadowroot
            // TODO _internals
        }
        connectedCallback() { return  spec.callbacks.connected() };
        disconnectedCallback() { return  spec.callbacks.disconnected() };
        adoptedCallback() { return  spec.callbacks.adopted() };
        attributeChangedCallback(name, old, new_) { return spec.callbacks.attributeChanged(name)(old)(new_)() };
    }
    customElements.define(name, Element);
}
