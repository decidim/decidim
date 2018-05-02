// = require_self

$("#result_decidim_accountability_status_id").change(function () {
  /* eslint-disable no-invalid-this */
  const progress = $(this).find(":selected").data("progress")
  if (progress || progress === 0) {
    $("#result_progress").val(progress);
  }
});

$(function() {
  $(document).on("open.zf.reveal", "#data_picker-modal", function () {
    let xhr = null;

    $("#data_picker-autocomplete").autoComplete({
      minChars: 2,
      source: function(term, response) {
        try {
          xhr.abort();
        } catch (exception) { xhr = null}

        let url = $("#proposal-picker-choose").attr("href")
        xhr = $.getJSON(
          url,
          { term: term },
          function(data) { response(data); }
        );
      },
      renderItem: function (item, search) {
        let sanitizedSearch = search.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&");
        let re = new RegExp(`(${sanitizedSearch.split(" ").join("|")})`, "gi");
        let title = item[0]
        let modelId = item[1]
        let val = `#${modelId}- ${title}`;
        return `<div class="autocomplete-suggestion" data-model-id="${modelId}" data-val ="${title}">${val.replace(re, "<b>$1</b>")}</div>`;
      },
      onSelect: function(event, term, item) {
        let choose = $("#proposal-picker-choose")
        let modelId = item.data("modelId")
        let val = `#${modelId}- ${item.data("val")}`;
        choose.data("picker-value", modelId)
        choose.data("picker-text", val)
        choose.data("picker-choose", "")
      }
    })
  });
})
