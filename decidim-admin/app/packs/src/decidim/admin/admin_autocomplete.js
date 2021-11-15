import AutoComplete from "@tarekraafat/autocomplete.js";
import axios from "axios";

$(() => {
  const $inputWrapper = $(".admin-autocomplete_search");
  const searchInputId = "#admin-autocomplete";
  const $searchInput = $(searchInputId);
  const $searchPrompt = $(".search_prompt");
  const $noResult = $(".no_result")
  const options = $inputWrapper.data();
  const threshold = 3;

  if ($inputWrapper.length < 1) {
    return;
  }

  console.log("options", options)
  const autoCompleteJS = new AutoComplete({
    name: "autocomplete",
    selector: searchInputId,
    // Delay (milliseconds) before autocomplete engine starts
    debounce: 200,
    threshold: threshold,
    data: {
      keys: ["label"],
      src: async (query) => {
        try {
          console.log("options.searchurl", options.searchurl);
          const cancelToken = axios.CancelToken.source().token;
          const response = await axios.get(options.searchurl, {
            cancelToken: cancelToken,
            headers: {
              Accept: "application/json"
            },
            withCredentials: true,
            params: {
              term: query
            }
          })
          return response.data
        } catch (error) {
          return error;
        }
      }
    },
    resultsList: {
      element: (list, data) => {
        if (data.results.length > 0) {
          $noResult.hide();
          $(list).removeClass("no_results");
        } else {
          $(list).addClass("no_results");
          $noResult.show();
        }
      },
      noResults: true
    },
    resultItem: {
      element: (item, data) => {
        item.innerHTML = `<span>${data.value.label}</span>`;
      }
    }
  });

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
    autoCompleteJS.input.value = "";
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
    const $acWrapper = $(".autocomplete_wrapper");
    const feedback = event.detail;
    const selection = feedback.selection;

    setSelection($acWrapper, selection.value.value, selection.value.label);
  })

  if (options.selected?.value && options.selected.label) {
    const $acWrapper = $(".autocomplete_wrapper");
    setSelection($acWrapper, options.selected.value, options.selected.label);
  }

  $("#autocomplete").on("open close", (event) => {
    event.stopPropagation();
  })
})


