"use strict";

exports.define_ = runMonad => name => observedAttributes => spec => () => {
    class Element extends HTMLElement {
        static get observedAttributes() { return observedAttributes };

        _runMonad(m) {
            this._state = runMonad(this)(this._state)(m)()
        }
        //TODO reflected properties
        constructor() {
            super();
            this._state = spec.initial;
            // TODO allow shadowroot
            // TODO _internals
        }
        connectedCallback() {
            this._runMonad(spec.callbacks.connected)
        };
        disconnectedCallback() {
            this._runMonad(spec.callbacks.disconnected)
        };
        adoptedCallback() {
            this._runMonad(spec.callbacks.adopted)
        };
        attributeChangedCallback(name, old, new_) {
            const m = spec.callbacks.attributeChanged(name)(old)(new_)
            this._runMonad(m);
        };
    }
    customElements.define(name, Element);
}
