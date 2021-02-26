((exports) => {

  /**
   * Returns a function, that, as long as it continues to be invoked, will not
   * be triggered. The function will be called after it stops being called for
   * N milliseconds.
   * @param {Object} context - the context for the called function.
   * @param {Function} func - the function to be executed.
   * @param {int} wait - number of milliseconds to wait before executing the function.
   * @private
   * @returns {Void} - Returns nothing.
   */
  exports.delayed = (context, func, wait) => {
    let timeout = null;

    return function(...args) {
      if (timeout) {
        clearTimeout(timeout);
      }
      timeout = setTimeout(() => {
        timeout = null;
        Reflect.apply(func, context, args);
      }, wait);
    }
  }
})(window);
