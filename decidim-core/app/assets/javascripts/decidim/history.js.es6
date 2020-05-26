/* eslint-disable no-prototype-builtins, no-restricted-syntax, no-param-reassign */
// require self

((exports) => {
  let callbacks = {};

  exports.onpopstate = (event) => {
    // Ensure the event is caused by user action
    if (event.isTrusted) {
      for (let callbackId in callbacks) {
        if (callbacks.hasOwnProperty(callbackId)) {
          callbacks[callbackId](event.state);
        }
      }
    }
  };

  const registerCallback = (callbackId, callback) => {
    callbacks[callbackId] = callback;
  };

  const unregisterCallback = (callbackId) => {
    callbacks[callbackId] = null;
  }

  const pushState = (url, state = null) => {
    if (window.history) {
      window.history.pushState(state, null, url);
    }
  };

  const replaceState = (url, state = null) => {
    if (window.history) {
      window.history.replaceState(state, null,  url);
    }
  };

  const state = () => {
    if (window.history) {
      return window.history.state;
    }
    return null;
  };

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.History = {
    registerCallback,
    unregisterCallback,
    pushState,
    replaceState,
    state
  };
})(window);
