// = require_self

$(function() {
  $("#result_decidim_accountability_status_id").change(function () {
    /* eslint-disable no-invalid-this */
    const progress = $(this).find(":selected").data("progress")
    if (progress || progress === 0) {
      $("#result_progress").val(progress);
    }
  });
})
