/* eslint-disable camelcase */
let controlSelector = function(source, prefix, currentValueKey) {
  if (source.length) {
    let currentValue = source.data(currentValueKey),
        searchUrl = source.data(`${prefix}-search-url`),
        targetElement = $(`#${source.data(`${prefix}-selector`)}`);

    if (targetElement.length) {
      let refresh = function () {
        $.ajax({
          url: searchUrl,
          cache: false,
          dataType: "html",
          data: {
            type_id: source.val(),
            selected: currentValue
          },
          success: function (data) {
            targetElement.html(data);
          }
        });
      };

      source.change(refresh);
      refresh();
    }
  }
};

$(document).ready(function () {
  let typeSelector = $("[data-scope-selector]");
  controlSelector(typeSelector, "scope", "scope-id");
  controlSelector(typeSelector, "signature-types", "signature-type");
});
