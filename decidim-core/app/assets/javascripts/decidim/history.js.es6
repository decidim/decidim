/* eslint-disable no-prototype-builtins, no-restricted-syntax, no-param-reassign */
// require self

((exports) => {
  let callbacks = {};

  exports.onpopstate = (event) => {
    // Ensure the event is caused by user action
    if (event.isTrusted) {
      for (let callbackId in callbacks) {
        if (callbacks.hasOwnProperty(callbackId)) {
          callbacks[callbackId]();
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

  const pushState = (url) => {
    if (window.history) {
      window.history.pushState(null, null, url);
    }
  };

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.History = {
    registerCallback,
    unregisterCallback,
    pushState
  };
})(window);
