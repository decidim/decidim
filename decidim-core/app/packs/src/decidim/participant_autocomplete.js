// import AutoComplete from "@tarekraafat/autocomplete.js";
// import * as AutoComplete from "./autocomplete"

import AutoComplete from "./autocomplete";

$(() => {
  const $fieldContainer = $(".autocomplete_search");
  const searchInputId = "#autocomplete";
  const $searchInput = $(searchInputId);
  const $selectedItems = $(".autocomplete_selected");
  const options = $fieldContainer.data();
  let selected = []

  if ($fieldContainer.length < 1) {
    return;
  }

  const autoComplete = new AutoComplete($searchInput[0], {
    dataMatchKeys: ["name", "nickname"],
    dataSource: (query, callback) => {
      $.post("/api", {
        "query": `
          {
            users(filter:{wildcard:"${query}",excludeIds:[]})
              {
                id,nickname,name,avatarUrl,__typename,...on UserGroup{membersCount},...on User{
                  directMessagesEnabled
                }
              }
          }`
      }).then((response) => {
        callback(response.data.users);
      });
    },
    dataFilter: (list) => {
      return list.filter(
        (item) => !selected.includes(item.value.id)
      );
    },
    modifyResult: (element, value) => {
      element.innerHTML = `
        <span class="author__avatar"><img src="${value.avatarUrl}"></span>
        <strong>${value.nickname}</strong>
        <small>${value.name}</small>
      `;
    }
  });

  $searchInput.on("selection", (event) => {
    const feedback = event.detail;
    const selection = feedback.selection;
    const id = selection.value.id;

    if (options.multiple === false) {
      console.log("selection.value", selection.value)
      $(".autocomplete_wrapper").append(`
        <span id="${selection.value.id}" role="option" aria-selected="true">
          ${selection.value.name} (${selection.value.nickname}) ${selection.value.email}
        </span>
      `)
      return;
    }

    $selectedItems.append(`
      <li>
        <input type="hidden" name="${options.name}" value="${selection.value.id}">
        ${selection.value.name}
        <div class="float-right" data-remove=${id} tabindex="0" aria-controls="0" aria-label="Close" role="tab">&times;</div>
      </li>
    `);

    autoComplete.setInput("");
    selected.push(id);

    $selectedItems.find(`*[data-remove="${id}"]`).on("keypress click", (evt) => {
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


