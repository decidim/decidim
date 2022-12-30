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
  proxy.dom = (callback) => {
    callback(el);
    return proxy;
  };
  proxy.append = (element, ...rest) => {
    if (rest.length > 0) {
      proxy.append(element);
      rest.forEach((subEl) => proxy.append(subEl));
      return proxy;
    }

    if (!element) {
      return proxy;
    } else if (element instanceof Function) {
      proxy.append(element());
      return proxy;
    } else if (element.render instanceof Function) {
      proxy.append(element.render());
      return proxy;
    } else if (element.childNodes.length < 1) {
      return proxy;
    }
    el.appendChild(element);
    return proxy;
  };
  proxy.render = (test) => {
    if (test instanceof Function && !test()) {
      return null;
    } else if (test === false) {
      return null;
    }
    return el;
  };

  return proxy;
};
