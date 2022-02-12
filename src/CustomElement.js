"use strict";

exports.define_ = runMonad => name => observedAttributes => spec => () => {
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
            this._state = runMonad(this._state)(spec.callbacks.connected)();
        };
        disconnectedCallback() {
            this._state = runMonad(this._state)(spec.callbacks.disconnected)();
        };
        adoptedCallback() {
            this._state = runMonad(this._state)(spec.callbacks.adopted)();
        };
        attributeChangedCallback(name, old, new_) {
            const m = spec.callbacks.attributeChanged(name)(old)(new_)
            this.state = runMonad(this._state)(m)();
        };
    }
    customElements.define(name, Element);
}
