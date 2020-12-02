((exports) => {
  // const Quill = exports.Quill;
  // const Delta = Quill.import("delta");

  const attributeDiff = (alpha, beta) => {
    console.log("alpha", alpha)
    console.log("beta", beta)
    if (typeof a !== "object") {
      alpha = {};
    }
    if (typeof b !== "object") {
      beta = {};
    }
    const attributes = Object.keys(alpha).concat(Object.keys(beta)).reduce((attrs, key) => {
      // if (!isEqual(a[key], b[key])) {
      if (alpha[key] !== beta[key]) {
        attrs[key] = beta[key] === undefined ? null : beta[key];
      }
      return attrs;
    }, {});
    // console.log("attributes", attributes)

    return Object.keys(attributes).length > 0 ? attributes : undefined;
  }

  exports.Editor.attributeDiff = attributeDiff
})(window)
