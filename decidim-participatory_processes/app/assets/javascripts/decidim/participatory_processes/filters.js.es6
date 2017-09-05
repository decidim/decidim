$(() => {
  ((exports) => {
    const $processesGrid = $('#processes-grid');
    const $loading = $processesGrid.find('.loading');
    const filterLinksSelector = '.order-by__tabs a'

    $loading.hide();

    $processesGrid.on('click', filterLinksSelector, (event) => {
      const $target = $(event.target);
      const $processesGridCards = $processesGrid.find('.card-grid .column');

      $(filterLinksSelector).removeClass('is-active');
      $target.addClass('is-active');

      $processesGridCards.hide();
      $loading.show();

      if (exports.history) {
        exports.history.pushState(null, null, $target.attr('href'));
      }
    });
  })(window);

});
