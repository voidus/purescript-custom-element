"use strict";

exports.define_ = helpers => name => observedAttributes => spec => () => {
    const h = helpers;
    function execStateT(f, s) { return h.execStateT(f)(s)() }

    class Element extends HTMLElement {
        static get observedAttributes() { return observedAttributes };
        //TODO reflected properties
        constructor() {
            super();
            this._state = spec.initial;
            // TODO allow shadowroot
            // TODO _internals
        }
        connectedCallback() {
            this._state = execStateT(spec.callbacks.connected, this._state);
        };
        disconnectedCallback() {
            this._state = execStateT(spec.callbacks.disconnected, this._state);
        };
        adoptedCallback() {
            this._state = execStateT(spec.callbacks.adopted, this._state);
        };
        attributeChangedCallback(name, old, new_) {
            this.state = execStateT(
                spec.callbacks.attributeChanged(name)(old)(new_),
                this._state
            );
        };
    }
    customElements.define(name, Element);
}
