import AutoComplete from "src/decidim/autocomplete";

$(() => {
  const $fieldContainer = $(".multiple-mentions");
  if ($fieldContainer.length < 1) {
    return;
  }

  const allMessages = window.Decidim.config.get("messages");
  const messages = allMessages.mentionsModal || {};

  const $searchInput = $("input", $fieldContainer);
  const $selectedItems = $(`ul.${$searchInput.data().selected}`);
  const options = $fieldContainer.data();
  let selected = [];
  const iconsPath = window.Decidim.config.get("icons_path");
  const removeLabel = messages.removeRecipient || "Remove recipient %name%";

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
      if (value.membersCount) {
        $(element).append(`<span class="is-group">${value.membersCount}x <svg class="icon--members icon"><use href="${iconsPath}#icon-members"/></svg></span>`);
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

    const label = removeLabel.replace("%name%", selection.value.name);
    $selectedItems.append(`
      <li>
        <input type="hidden" name="${options.name}" value="${id}">
        <img src="${selection.value.avatarUrl}" class="author__avatar" alt="${selection.value.name}">
        <b>${selection.value.name}</b>
        <button type="button" class="float-right" data-remove="${id}" tabindex="0" aria-controls="0" aria-label="${label}">&times;</button>
      </li>
    `);

    autoComplete.setInput("");
    selected.push(id);

    $selectedItems.find(`*[data-remove="${id}"]`).on("keypress click", (evt) => {
      const target = evt.target.parentNode;
      if (target.tagName === "LI") {
        selected = selected.filter((identifier) => identifier !== id);
        target.remove();
      }
    })
  })
})
