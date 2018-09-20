/* eslint-disable no-ternary */
((exports) => {
  const { createSortList } = exports.DecidimAdmin;

  // Once in DOM
  $(() => {
    const selector = ".js-sortable"
    const $sortable = $(selector)

    $sortable.each((index, elem) => {
      const item = (elem.id)
        ? `#${elem.id}`
        : selector

      createSortList(item, {
        handle: "li",
        forcePlaceholderSize: true,
        placeholderClass: "sort-placeholder"
      })
    })
  })
})(window)
