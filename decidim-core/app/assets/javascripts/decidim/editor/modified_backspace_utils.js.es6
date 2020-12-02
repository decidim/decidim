((exports) => {
  // const Quill = exports.Quill;
  // const Delta = Quill.import("delta");

  const attributeDiff = (alpha, beta) => {
    if (typeof alpha !== "object") {
      alpha = {};
    }
    if (typeof beta !== "object") {
      beta = {};
    }
    const attributes = Object.keys(alpha).concat(Object.keys(beta)).reduce((attrs, key) => {
      // ORGINAL: import isEqual from 'lodash.isequal'; if (!isEqual(a[key], b[key]))
      if ((alpha[key] !== beta[key])) {
        attrs[key] = beta[key] === undefined ? null : beta[key];
      }
      return attrs;
    }, {});

    return  Object.keys(attributes).length > 0 ? attributes : undefined;
  }

  exports.Editor.attributeDiff = attributeDiff
})(window)
