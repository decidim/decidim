import AutoComplete from "src/decidim/autocomplete"

$(() => {
  const $fieldContainer = $(".autocomplete_search");
  const $searchInput = $("input", $fieldContainer);
  const $selectedItems = $(`ul.${$searchInput.data().selected}`);
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
      $(element).html(`
        <span class="author__avatar"><img src="${value.avatarUrl}" alt="${value.name}"></span>
        <strong>${value.nickname}</strong>
        <small>${value.name}</small>
      `);
      if (value.directMessagesEnabled === "false") {
        $(element).addClass("disabled");
        $(element).append(`<span>${$searchInput.data().directMessagesDisabled}</span>`);
      }
    }
  });

  $searchInput.on("selection", (event) => {
    const feedback = event.detail;
    const selection = feedback.selection;
    const id = selection.value.id;
    if (selected.length >= 9 || selection.value.directMessagesEnabled === "false") {
      return;
    }

    $selectedItems.append(`
      <li>
        <input type="hidden" name="${options.name}" value="${selection.value.id}">
        <img src="${selection.value.avatarUrl}" class="author__avatar" alt="${selection.value.name}">
        <b>${selection.value.name}</b>
        <button class="float-right" data-remove=${id} tabindex="0" aria-controls="0" aria-label="Close" role="tab">&times;</button>
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
  $searchInput.on("open close", (event) => {
    event.stopPropagation();
  })
})


