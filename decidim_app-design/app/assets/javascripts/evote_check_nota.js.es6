// Evote: disables all other options
// if none-of-the-above option is checked
(() => {
  $(() => {
    $("[data-disable-check]").prop("checked", false);

    $("[data-disabled-by]").on("click", (event) => {
      const $target = $(event.currentTarget);
      if ($target.attr("aria-disabled") || $target.hasClass("is-disabled")) {
        event.preventDefault();
      }
    });

    $("[data-disable-check]").on("change", (event) => {
      const target = event.currentTarget;
      let checkId = $(target).attr("id");
      let checkStatus = target.checked;

      $(`[data-disabled-by='#${checkId}'`).each((index, obj) => {
        const $check = $(obj);
        if (checkStatus) {
          $check.addClass("is-disabled");
          $check.find("input[type=checkbox]").prop("checked", false);
        } else {
          $check.removeClass("is-disabled");
        }

        $check.find("input[type=checkbox]").attr("aria-disabled", checkStatus);
      });
    });
  });
})(window);
