// = require html.sortable

((exports) => {

  const sortList = (sortListSelector, options) => {
    if ($(sortListSelector).length > 0) {
      window.sortable(sortListSelector, options)[0].addEventListener('sortupdate', (event) => {
        const $children = $(event.target).children();

        if (options.onSortUpdate) {
          options.onSortUpdate($children);
        }
      });
    }
  };

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.sortList = sortList;
})(window);
