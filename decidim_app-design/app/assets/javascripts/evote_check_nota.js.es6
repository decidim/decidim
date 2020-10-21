// Evote: disables all other options
// if none-of-the-above option is checked
(() => {
  $(() => {
    $("[data-disable-check]").prop("checked", false);

    $("[data-disable-check]").on("change", function() {
      let checkId = $(this).attr("id");
      let checkStatus = this.checked;

      $("[data-disabled-by='#" + checkId + "']").each(function() {
        $(this).attr("disabled", checkStatus);
        $(this)
          .find("input[type=checkbox]")
          .attr("disabled", checkStatus);
        if (checkStatus) {
          $(this)
            .find("input[type=checkbox]")
            .prop("checked", false);
        }
      });
    });
  });
})(window);
