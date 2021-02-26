// ORGINAL: https://github.com/quilljs/delta/blob/ddda3bf088cda3ec03d5dbcc1179679d147f3a02/src/AttributeMap.ts

((exports) => {
  const attributeDiff = (attributes1, attributes2) => {
    let alpha = attributes1;
    let beta = attributes2;
    if (typeof alpha !== "object") {
      alpha = {};
    }
    if (typeof beta !== "object") {
      beta = {};
    }
    const attributes = Object.keys(alpha).concat(Object.keys(beta)).reduce((attrs, key) => {
      // ORGINAL: import isEqual from 'lodash.isequal'; if (!isEqual(a[key], b[key]))
      if ((alpha[key] !== beta[key])) {
        attrs[key] = null;
        if (beta[key]) {
          attrs[key] = beta[key]
        }
      }
      return attrs;
    }, {});

    if (Object.keys(attributes).length > 0) {
      return attributes;
    }
    return null;
  }

  exports.Decidim.Editor.attributeDiff = attributeDiff
})(window)
