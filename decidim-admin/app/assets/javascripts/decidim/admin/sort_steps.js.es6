/* global sortable */

// consider removing from application.js file
//
// Needs a `tbody` element inside a `#steps` section. The `tbody` element
// should have a `data-sort-url` attribute with the URL where the data should
// be posted to.
$(() => {
 sortSteps();
});
$( document ).on('turbolinks:load' , function() {
  sortSteps();
});

function sortSteps(){
  const sortableElement = $('#steps tbody');

  if (sortableElement[0]) {
    const sortUrl = sortableElement.data('sort-url');

    sortable('#steps tbody', {
      placeholder: $('<tr style="border-style: dashed; border-color: #000"><td colspan="4">&nbsp;</td></tr>')[0]
    })[0].addEventListener('sortupdate', (e) => {
      const order = $(e.target).children().map((index, child) => $(child).data('id')).toArray();

      $.ajax({
        method: 'POST',
        url: sortUrl,
        contentType: 'application/json',
        data: JSON.stringify({ items_ids: order }) },
      );
    });
  }
}
