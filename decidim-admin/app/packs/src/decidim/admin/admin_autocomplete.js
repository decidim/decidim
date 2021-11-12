import AutoComplete from "@tarekraafat/autocomplete.js";
import axios from "axios";

const parseResults = (response) => {
  if (!response.data) {
    return []
  }

  const suggestions = response.data.map((user) => (
    {
      "id": user.value,
      "label": user.label
    }
  ))
  console.log("suggestions", suggestions)
  return suggestions
}

$(() => {
  const $inputWrapper = $(".admin-autocomplete_search");
  const searchInputId = "#admin-autocomplete";
  const $searchInput = $(searchInputId);
  const options = $inputWrapper.data();
  let selected = []

  if ($inputWrapper.length < 1) {
    return;
  }

  console.log("options.placeholder", options.placeholder)
  const autoCompleteJS = new AutoComplete({
    name: "autocomplete",
    selector: searchInputId,
    // Delay (milliseconds) before autocomplete engine starts
    debounce: 200,
    threshold: 3,
    data: {
      src: async (query) => {
        try {
          console.log("options.searchurl", options.searchurl)
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
          return parseResults(response);
        } catch (error) {
          return error;
        }
      },
      keys: ["label"],
      filter: (list) => {
        if (options.multiple === false) {
          return list
        }
        const filtered = [];
        const ids = [];

        // Remove duplicates
        for (let idx = 0; idx < list.length; idx += 1) {
          const item = list[idx];
          if (!ids.includes(item.value.id) && !selected.includes(item.value.id)) {
            ids.push(item.value.id);
            filtered.push(item);
          }
        }

        return filtered
      }
    },
    resultItem: {
      element: (item, data) => {
        item.innerHTML = `<span>${data.value.label}</span>`
      }
    }
  });

  const resetInput = ($target) => {
    $target.attr("placeholder", options.placeholder);
    $target.removeClass("selected");
  }

  $searchInput.on("keyup", (evt) => {
    if ($searchInput.val().length > 0) {
      $searchInput.siblings(".current-selection").remove();
      resetInput($searchInput);
    } else if ($(evt.target).siblings(".current-selection").length === 0) {
      resetInput($searchInput);
    }
  })

  $searchInput.on("selection", (event) => {
    const $acWrapper = $(".autocomplete_wrapper");
    const feedback = event.detail;
    const selection = feedback.selection;
    autoCompleteJS.input.value = "";
    $searchInput.attr("placeholder", "");
    $searchInput.addClass("selected");

    $acWrapper.prepend(`
      <div id="selected-${selection.value.id}" class="current-selection">
        <input type="hidden" name="${options.name}" value="${selection.value.id}">
        <span class="clear-selection" data-remove=${selection.value.id} aria-label="Clear value" title="Clear value">&times;</span>
        <span class="selected-value" role="option" aria-selected="true">
          ${selection.value.label}
        </span>
      </div>
    `)

    $acWrapper.find(`*[data-remove="${selection.value.id}"]`).on("keypress click", (evt) => {
      resetInput($searchInput);
      $(`#selected-${selection.value.id}`).remove();
      evt.target.remove();
    });
  })

  $("#autocomplete").on("open close", (event) => {
    event.stopPropagation();
  })
})


