/* eslint-disable require-jsdoc */
/* eslint-disable no-prototype-builtins, no-restricted-syntax, no-param-reassign */

let callbacks = {};

export default function registerCallback(callbackId, callback) {
  callbacks[callbackId] = callback;
}

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

$(() => {
  window.onpopstate = (event) => {
    // Ensure the event is caused by user action
    if (event.isTrusted) {
      for (let callbackId in callbacks) {
        if (callbacks.hasOwnProperty(callbackId)) {
          callbacks[callbackId](event.state);
        }
      }
    }
  }
});

export { registerCallback, unregisterCallback, pushState, replaceState, state };
