// = require_self

$("#result_decidim_accountability_status_id").change(function () {
  progress = $(this).find(':selected').data('progress')
  if (progress || progress == 0) {
    $("#result_progress").val(progress);
  }
});
