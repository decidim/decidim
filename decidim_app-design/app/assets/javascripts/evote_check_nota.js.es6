// Evote: disables all other options
// if none-of-the-above option is checked
(() => {
  $(() => {
    $("[data-disable-check]").prop("checked", false);

    $("[data-disabled-by]").on("click", function(e) {
      if ($(this).attr("aria-disabled") || $(this).hasClass("is-disabled")) {
        e.preventDefault();
      }
    });

    $("[data-disable-check]").on("change", function() {
      let checkId = $(this).attr("id");
      let checkStatus = this.checked;

      $("[data-disabled-by='#" + checkId + "']").each(function() {
        if (checkStatus) {
          $(this).addClass("is-disabled");
          $(this)
            .find("input[type=checkbox]")
            .prop("checked", false);
        } else {
          $(this).removeClass("is-disabled");
        }

        $(this)
          .find("input[type=checkbox]")
          .attr("aria-disabled", checkStatus);
      });
    });
  });
})(window);
