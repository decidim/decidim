import AutoComplete from "src/decidim/autocomplete";

$(() => {
  const threshold = 3;

  const $autocompleteDiv = $("[data-plugin='autocomplete']");
  console.log("$searchInput", $autocompleteDiv)
  if ($autocompleteDiv.length < 1) {
    return;
  }

  const options = $autocompleteDiv.data();
  console.log("options", options);
  const autoComplete = AutoComplete.autoConfigure($autocompleteDiv[0]);

  const $wrapper = $(".autoComplete_wrapper");
  const $searchInput = $wrapper.find("input");
  $wrapper.append(`<div class="search_prompt" style="display: none;">${options.autocomplete.searchPromptText}</div>`);
  $wrapper.append(`<div class="no_result" style="display: none;">${options.autocomplete.noResultsText}</div>`);
  const $searchPrompt = $(".search_prompt", $wrapper);
  const $noResult = $(".no_result", $wrapper);

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

  $searchInput.on("keyup", (event) => {
    console.log("event", event.originalEvent);
    const keyPressed = event.originalEvent.key;
    if (["Backspace", "Delete"].includes(keyPressed)) {
      resetInput($(event.target));
      return;
    }

    const inputCount = $searchInput.val().length;
    if (inputCount > 0) {
      $searchInput.siblings(".current-selection").remove();
      resetInput($searchInput);
      if (inputCount < threshold) {
        $searchPrompt.show();
        $noResult.hide();
      } else {
        $searchPrompt.hide();
      }
    } else if (inputCount === 0 && $(event.target).siblings(".current-selection").length === 0) {
      resetInput($searchInput);
    }
  })

  const setSelection = ($target, value, label) => {
    autoComplete.setInput("");
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

  $searchInput.on("selection", (event) => {
    const feedback = event.detail;
    const selection = feedback.selection;

    setSelection($wrapper, selection.value.value, selection.value.label);
  })

  if (options.selected?.value && options.selected.label) {
    setSelection($wrapper, options.selected.value, options.selected.label);
  }

  $("#autocomplete").on("open close", (event) => {
    event.stopPropagation();
  })
})


