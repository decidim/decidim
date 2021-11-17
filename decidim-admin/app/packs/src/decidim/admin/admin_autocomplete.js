import AutoComplete from "src/decidim/autocomplete";

$(() => {
  // const $inputWrapper = $(".admin-autocomplete_search");
  const searchInputId = "#admin-autocomplete";
  const $searchInput = $(searchInputId);
  const $searchPrompt = $(".search_prompt");
  const $noResult = $(".no_result")
  // const threshold = 3;

  const autocompleteDiv = document.querySelector("[data-plugin='autocomplete']");
  const options = autocompleteDiv.dataset;

  if (autocompleteDiv.length < 1) {
    return;
  }

  AutoComplete.autoConfigure(autocompleteDiv);

  const resetInput = ($target) => {
    console.log("reset", $target);
    $target.siblings(".current-selection").remove();
    $target.attr("placeholder", options.placeholder);
    $target.removeClass("selected");
  }

  $searchInput.on("focusout", (event) => {
    event.target.value = "";
    $searchPrompt.hide();
    $noResult.hide();
  })

  // $searchInput.on("keyup", (event) => {
  //   console.log("event", event.originalEvent);
  //   const keyPressed = event.originalEvent.key;
  //   if (["Backspace", "Delete"].includes(keyPressed)) {
  //     resetInput($(event.target));
  //     return;
  //   }

  //   const inputCount = $searchInput.val().length;
  //   if (inputCount > 0) {
  //     $searchInput.siblings(".current-selection").remove();
  //     resetInput($searchInput);
  //     if (inputCount < threshold) {
  //       $searchPrompt.show();
  //       $noResult.hide();
  //     } else {
  //       $searchPrompt.hide();
  //     }
  //   } else if (inputCount === 0 && $(event.target).siblings(".current-selection").length === 0) {
  //     resetInput($searchInput);
  //   }
  // })

  const setSelection = ($target, value, label) => {
    // autoCompleteJS.input.value = "";
    $searchInput.attr("placeholder", "");
    $searchInput.addClass("selected");

    $target.prepend(`
      <div id="selected-${value}" class="current-selection">
        <input type="hidden" name="${options.name}" value="${value}">
        <span class="clear-selection" data-remove=${value} aria-label="Clear value" title="Clear value">&times;</span>
        <span class="selected-value" role="option" aria-selected="true">
          ${label}
        </span>
      </div>
    `)

    $target.find(`*[data-remove="${value}"]`).on("keypress click", (evt) => {
      resetInput($(evt.target).parent().siblings("input"));
    });
  }

  // $searchInput.on("selection", (event) => {
  //   const $acWrapper = $(".autocomplete_wrapper");
  //   const feedback = event.detail;
  //   const selection = feedback.selection;

  //   setSelection($acWrapper, selection.value.value, selection.value.label);
  // })

  if (options.selected?.value && options.selected.label) {
    const $acWrapper = $(".autocomplete_wrapper");
    setSelection($acWrapper, options.selected.value, options.selected.label);
  }

  $("#autocomplete").on("open close", (event) => {
    event.stopPropagation();
  })
})


