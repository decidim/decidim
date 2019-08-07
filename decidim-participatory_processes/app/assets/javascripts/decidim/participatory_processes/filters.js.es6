$(() => {
  ((exports) => {
    const $processesGrid = $("#processes-grid");
    const $loading = $processesGrid.find(".loading");
    const filterLinksSelector = ".order-by__tabs a"

    $loading.hide();

    $processesGrid.on("click", filterLinksSelector, (event) => {
      const $processesGridCards = $processesGrid.find(".card-grid .column");
      let $target = $(event.target);

      // IE11 matches the <strong> element inside the filtering anchor element
      // as the `event.target` breaking the functionality below.
      if (!$target.is("a")) {
        $target = $target.parents("a");
      }

      $(filterLinksSelector).removeClass("is-active");
      $target.addClass("is-active");

      $processesGridCards.hide();
      $loading.show();

      if (exports.history) {
        exports.history.pushState(null, null, $target.attr("href"));
      }
    });
  })(window);

});
