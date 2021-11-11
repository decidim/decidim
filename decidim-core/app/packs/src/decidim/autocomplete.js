import AutoComplete from "@tarekraafat/autocomplete.js";
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

  const suggestions = response.data.users.map(user => (
    {
      "id": user.id,
      "nickname": user.nickname,
      "name": user.name,
      "avatar": user.avatarUrl
    }
  ))
  return suggestions
}


$(() => {
  const $inputWrapper = $(".autocomplete_search");
  const searchInputId = "#autocomplete";
  const $searchInput = $(searchInputId);
  const $results = $(".autocomplete_results");
  const options = $inputWrapper.data();
  let selected = []

  if ($inputWrapper.length < 1) {
    return;
  }

  console.log("wrapper", $inputWrapper);

  const autoCompleteJS = new AutoComplete({
    name: "autocomplete",
    selector: searchInputId,
    debounce: 200, // Delay (milliseconds) before autocomplete engine starts
    data: {
      src: async (query) => {
        try {
          const response = await $.post("/api", {
            "query": `
              {
                users(filter:{wildcard:"${query}",excludeIds:[]})
                  {
                    id,nickname,name,avatarUrl,__typename,...on UserGroup{membersCount},...on User{
                      directMessagesEnabled
                    }
                  }
              }`
          });
          return parseResults(response);
        } catch (error) {
          return error;
        }
      },
      keys: ["name", "nickname"],
      filter: (list) => {
        const filtered = [];
        const ids = [];

        // Remove duplicates
        for (let i = 0; i < list.length; i++) {
          const item = list[i];
          if (ids.includes(item.value.id) || selected.includes(item.value.id)) {
            continue;
          }
          ids.push(item.value.id);
          filtered.push(item);
        }

        return filtered
      }
    },
    resultItem: {
      element: (item, data) => {
        item.innerHTML = `
        <span><img src="${data.value.avatar}"></span>
        <strong>${data.value.nickname}</strong>
        <small>${data.value.name}</small>`;
      }
    }
  });

  // console.log("acj", autoCompleteJS)
  // console.log("attr", $inputWrapper.data())

  $searchInput.on("selection", (event) => {
    const feedback = event.detail;
    const selection = feedback.selection;
    const id = selection.value.id;

    if (options.multiple === false) {
      autoCompleteJS.input.value = selection.value.name
      return;
    }

    $results.append(`
      <li>
        <input type="hidden" name="${options.name}" value="${selection.value.id}">
        ${selection.value.name}
        <div class="float-right" data-remove=${id} tabindex="0" aria-controls="0" aria-label="Close" role="tab">&times;</div>
      </li>
    `);

    autoCompleteJS.input.value = "";
    selected.push(id);
    console.log("input", autoCompleteJS.input)

    $results.find(`*[data-remove="${id}"]`).on("keypress click", (event) => {
      const target = event.target.parentNode;
      if (target.tagName === "LI") {
        selected = selected.filter(identifier => identifier !== id)
        target.remove();
      }
    })
  })

  // $("#autocomplete").on("navigate", (event) => {
  //   // "event.detail" carries the autoComplete.js "feedback" object
  //   console.log(event.detail);
  // });

  // Stop input field from bubbling open and close events to parent elements,
  // because foundation closes modal from these events.
  $("#autocomplete").on("open close", (event) => {
    event.stopPropagation();
  })
})


