/**
 * Calls the provided function and returns the proxy object after the call.
 *
 * @param {*} proxy The proxy object to return after the call.
 * @param {Function} callable The method to call.
 * @returns {*} The provided proxy object
 */
const proxyCall = (proxy, callable) => (...args) => {
  callable(...args);
  return proxy;
}

/**
 * Provides a HTML utility to control the HTML rendering more easily and add
 * support for conditional rendering.
 *
 * @param {String} tag The name of the HTML tag to be created.
 * @returns {Object} A proxy object to control the HTML rendering of the
 *   elements.
 */
export default (tag = "div") => {
  const el = document.createElement(tag);

  const proxy = {};
  proxy.dom = proxyCall(proxy, (callback) => callback(el));
  proxy.append = proxyCall(proxy, (element, ...rest) => {
    if (rest.length > 0) {
      proxy.append(element);
      rest.forEach((subEl) => proxy.append(subEl));
      return;
    } else if (!element) {
      return;
    }

    if (element instanceof Function) {
      proxy.append(element());
    } else if (element?.render instanceof Function) {
      proxy.append(element.render());
    } else if (element instanceof Node && element.childNodes.length > 0) {
      el.appendChild(element);
    }
  });
  proxy.render = (condition) => {
    if (condition instanceof Function && !condition(el)) {
      return null;
    } else if (condition === false) {
      return null;
    }
    return el;
  };

  return proxy;
};
