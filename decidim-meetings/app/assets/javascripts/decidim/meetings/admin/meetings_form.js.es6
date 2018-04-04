$(() => {
  ((exports) => {
    const $form = $(".edit_meeting, .new_meeting");

    if ($form.length > 0) {
      const $meetingOpenType = $form.find("#meeting_open_type");
      const $meetingOpenTypeOther = $form.find("#meeting_open_type_other");

      const $meetingPublicType = $form.find("#meeting_public_type");
      const $meetingPublicTypeOther = $form.find("#meeting_public_type_other");

      const $meetingTransparentType = $form.find("#meeting_transparent_type");
      const $meetingTransparentTypeOther = $form.find("#meeting_transparent_type_other");

      const toggleDependsOnSelect = ($target, $showDiv) => {
        const value = $target.val();
        $showDiv.hide();
        if (value === "other") {
          $showDiv.show();
        }
      };

      $meetingOpenType.on("change", (ev) => {
        const $target = $(ev.target);
        toggleDependsOnSelect($target, $meetingOpenTypeOther);
      });

      $meetingPublicType.on("change", (ev) => {
        const $target = $(ev.target);
        toggleDependsOnSelect($target, $meetingPublicTypeOther);
      });

      $meetingTransparentType.on("change", (ev) => {
        const $target = $(ev.target);
        toggleDependsOnSelect($target, $meetingTransparentTypeOther);
      });


      toggleDependsOnSelect($meetingOpenType, $meetingOpenTypeOther);
      toggleDependsOnSelect($meetingPublicType, $meetingPublicTypeOther);
      toggleDependsOnSelect($meetingTransparentType, $meetingTransparentTypeOther);

      $(document).on("open.zf.reveal", "#data_picker-modal", function () {
        let xhr = null;

        $("#data_picker-autocomplete").autoComplete({
          minChars: 2,
          source: function(term, response) {
            try {
              xhr.abort();
            } catch (exception) { xhr = null}

            xhr = $.getJSON(
              "organizers.json",
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
            let choose = $("#user-picker-choose");
            let modelId = item.data("modelId");
            let val = `${item.data("val")}`;
            choose.data("picker-value", modelId);
            choose.data("picker-text", val);
            choose.data("picker-choose", "")
          }
        })
      });
    }
  })(window);
});
