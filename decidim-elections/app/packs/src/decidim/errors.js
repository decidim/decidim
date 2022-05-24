export function reportingErrors(fn) {
    return function () {
      try {
        return fn.apply(this);
      } catch (e) {
        alert(e);
        console.error(e);
        throw e;
      }
    };
  };

export function reportingErrorsAsync(fn) {
    return async function () {
      try {
        return await fn.apply(this);
      } catch (e) {
        alert(e);
        console.error(e);
        throw e;
      }
    };
  };

