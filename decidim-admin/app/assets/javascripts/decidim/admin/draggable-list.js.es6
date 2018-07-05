((exports) => {
  const { createSortList } = exports.DecidimAdmin;

  const createSortableList = (lists) => {
    createSortList(lists, {
      handle: "li",
      forcePlaceholderSize: true,
      connectWith: ".js-connect"
    })
  };

  // Once in DOM
  $(() => {
    const $draggables = $(".draggable-list")
    let draggablesClassNames = []
    $draggables.each((index, elem) => {
      draggablesClassNames = [...draggablesClassNames, `.${elem.className.split(" ").filter((name) => (/js-list.*/).test(name))[0]}`]
    })

    createSortableList(draggablesClassNames.join(", "))
  })
})(window)
