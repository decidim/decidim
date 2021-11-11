import AutoComplete from "@tarekraafat/autocomplete.js";
import axios from "axios";
// import * as AutoComplete from "@tarekraafat/autocomplete.js"
// const autoComplete = require("@tarekraafat/autocomplete.js")
// const autoComplete = require("@tarekraafat/autocomplete.js/dist/autoComplete")
// import { autoComplete } from "@tarekraafat/autocomplete.js/dist/autoComplete"
// import { autoComplete } from "@tarekraafat/autocomplete.js/src"
// import * as AutoComplete from "./autocomplete"

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
    console.log("ADMIN-RETURNAA")
    return;
  }

  console.log("wrapper", $inputWrapper);

  const autoCompleteJS = new AutoComplete({
    name: "autocomplete",
    selector: searchInputId,
    // Delay (milliseconds) before autocomplete engine starts
    debounce: 200,
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

  // console.log("acj", autoCompleteJS)
  // console.log("attr", $inputWrapper.data())

  $searchInput.on("selection", (event) => {
    const feedback = event.detail;
    const selection = feedback.selection;
    const $wrapper = $(".autocomplete_wrapper")
    autoCompleteJS.input.value = ""

    $wrapper.prepend(`
      <span class="clear-selection" data-remove=${selection.value.id} aria-label="Clear value" title="Clear value">&times;</span>
    `)
    $wrapper.prepend(`
      <span id="selected-${selection.value.id}" class="selected-value" role="option" aria-selected="true">
        ${selection.value.label}
      </span>

    `)

    $wrapper.find(`*[data-remove="${selection.value.id}"]`).on("keypress click", (evt) => {
      $(`#selected-${selection.value.id}`).remove();
      evt.target.remove();
    });
  })

  $("#autocomplete").on("open close", (event) => {
    event.stopPropagation();
  })
})


