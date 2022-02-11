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
        attributeChangedCallback() { return  spec.callbacks.attributeChanged.apply(null, arguments) };
    }
    customElements.define(name, Element);
}
