import AutoComplete from "@tarekraafat/autocomplete.js";
// import * as AutoComplete from "./autocomplete"

$(() => {
  const $fieldContainer = $(".autocomplete_search");
  const searchInputId = "#autocomplete";
  const $searchInput = $(searchInputId);
  const $results = $(".autocomplete_results");
  const options = $fieldContainer.data();
  const threshold = options?.threshold || 2;
  let selected = []

  if ($fieldContainer.length < 1) {
    return;
  }

  const autoCompleteJS = new AutoComplete({
    name: "autocomplete",
    selector: searchInputId,
    // Delay (milliseconds) before autocomplete engine starts
    debounce: 200,
    threshold: threshold,
    data: {
      keys: ["name", "nickname"],
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

          console.log("results", response.data.users);
          return response.data.users
        } catch (error) {
          return error;
        }
      },
      filter: (list) => {
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
    resultsList: {
      maxResults: 10
    },
    resultItem: {
      element: (item, data) => {
        console.log("item", item);
        console.log("data", data)
        item.innerHTML = `
        <span><img src="${data.value.avatarUrl}"></span>
        <strong>${data.value.nickname}</strong>
        <small>${data.value.name}</small>`;
      }
    }
  });

  $searchInput.on("selection", (event) => {
    const feedback = event.detail;
    const selection = feedback.selection;
    const id = selection.value.id;

    if (options.multiple === false) {
      // autoCompleteJS.input.value = selection.value.name
      console.log("selection.value", selection.value)
      $(".autocomplete_wrapper").append(`
        <span id="${selection.value.id}" role="option" aria-selected="true">
          ${selection.value.name} (${selection.value.nickname}) ${selection.value.email}
        </span>
      `)
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

    $results.find(`*[data-remove="${id}"]`).on("keypress click", (evt) => {
      const target = evt.target.parentNode;
      if (target.tagName === "LI") {
        selected = selected.filter((identifier) => identifier !== id)
        target.remove();
      }
    })
  })

  // Stop input field from bubbling open and close events to parent elements,
  // because foundation closes modal from these events.
  $("#autocomplete").on("open close", (event) => {
    event.stopPropagation();
  })
})


