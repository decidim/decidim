/* eslint-disable camelcase */

$(document).ready(function () {
  let typeSelector = $("[data-scope-selector]");

  if (typeSelector.length) {
    let currentValue = typeSelector.data("scope-id"),
        searchUrl = typeSelector.data("scope-search-url"),
        targetElement = $(`#${typeSelector.data("scope-selector")}`);

    if (targetElement.length) {
      let refresh = function () {
        $.ajax({
          url: searchUrl,
          cache: false,
          dataType: "html",
          data: {
            type_id: typeSelector.val(),
            selected: currentValue
          },
          success: function (data) {
            targetElement.html(data);
          }
        });
      };

      typeSelector.change(refresh);
      refresh();
    }
  }
});
