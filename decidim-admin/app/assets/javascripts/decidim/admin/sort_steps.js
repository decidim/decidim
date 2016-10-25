/* global sortable */

// consider removing from application.js file
//
// Needs a `tbody` element inside a `#steps` section. The `tbody` element
// should have a `data-sort-url` attribute with the URL where the data should
// be posted to.
$(function() {
  var sortableElement = $("#steps tbody");

  if (sortableElement) {
    var sortUrl = sortableElement.data("sort-url");

    sortable("#steps tbody", {
      placeholder: $('<tr style="border-style: dashed; border-color: #000"><td colspan="4">&nbsp;</td></tr>')[0]
    })[0].addEventListener('sortupdate', function(e) {
      var order = $(e.target).children().map(function() { return $(this).data("id") }).toArray();
      $.ajax({ method: "POST", url: sortUrl, data: { "items_ids": order } });
    });
  }
});
