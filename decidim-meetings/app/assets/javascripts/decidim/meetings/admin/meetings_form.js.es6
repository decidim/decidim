$(() => {
  const $form = $(".edit_meeting, .new_meeting, .copy_meetings");

  if ($form.length > 0) {
    const $isPrivate = $form.find("#is_private");
    const $isTransparent = $form.find("#is_transparent");

    const toggleDisabledHiddenFields = () => {
      const enabledPrivateSpace = $isPrivate.find("input[type='checkbox']").prop("checked");
      $isTransparent.find("input[type='checkbox']").attr("disabled", "disabled");

      if (enabledPrivateSpace) {
        $isTransparent.find("input[type='checkbox']").attr("disabled", !enabledPrivateSpace);
      }
    };

    $isPrivate.on("change", toggleDisabledHiddenFields);
    toggleDisabledHiddenFields();

    let xhr = null;

    $(".user-autocomplete").autoComplete({
      minChars: 2,
      source: function(term, response) {
        try {
          xhr.abort();
        } catch (exception) { xhr = null }

        xhr = $.getJSON(
          $(".user-autocomplete").data("url"),
          { term: term },
          function(data) { response(data); }
        );
      },
      renderItem: function (item, search) {
        let sanitizedSearch = search.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&");
        let re = new RegExp(`(${sanitizedSearch.split(" ").join("|")})`, "gi");
        let modelId = item[0];
        let name = item[1];
        let nickname = item[2];
        let val = `${name} (@${nickname})`;
        return `<div class="autocomplete-suggestion" data-model-id="${modelId}" data-val="${val}">${val.replace(re, "<b>$1</b>")}</div>`;
      },
      onSelect: function(event, term, item) {
        let modelId = item.data("modelId");
        let val = `${item.data("val")}`;
        $("#meeting_organizer_id").val(modelId);
        $(".user-autocomplete").val(val);
      }
    });
  }
});
