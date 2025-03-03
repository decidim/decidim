import AutoComplete from "src/decidim/autocomplete";
import icon from "src/decidim/icon";

const updateSubmitButton = ($fieldContainer, $selectedItems) => {
  const $form = $fieldContainer.closest("form");
  if ($form.length < 1) {
    return;
  }

  const $submitButton = $form.find("button[type='submit']");
  if ($selectedItems.children().length === 0) {
    $submitButton.prop("disabled", true);
  } else {
    $submitButton.prop("disabled", false);
  }
}

$(() => {
  const $fieldContainer = $(".js-multiple-mentions");
  if ($fieldContainer.length < 1) {
    return;
  }

  const allMessages = window.Decidim.config.get("messages");
  const messages = allMessages.mentionsModal || {};

  const $searchInput = $("input", $fieldContainer);
  const $selectedItems = $(`ul.${$searchInput.data().selected}`);
  const options = $fieldContainer.data();
  let selected = [];
  const removeLabel = messages.removeRecipient || "Remove recipient %name%";

  let emptyFocusElement = $fieldContainer[0].querySelector(".empty-list");
  if (!emptyFocusElement) {
    emptyFocusElement = document.createElement("div");
    emptyFocusElement.tabIndex = "-1";
    emptyFocusElement.className = "empty-list";
    $selectedItems.before(emptyFocusElement);
  }

  updateSubmitButton($fieldContainer, $selectedItems);
  const autoComplete = new AutoComplete($searchInput[0], {
    dataMatchKeys: ["name", "nickname"],
    dataSource: (query, callback) => {
      $.post(window.Decidim.config.get("api_path"), {
        "query": `
          {
            users(filter:{wildcard:"${query}",excludeIds:[]})
              {
                id,nickname,name,avatarUrl,__typename,...on User {
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
        <img src="${value.avatarUrl}" alt="${value.name}">
        <span>${value.nickname}</span>
        <small>${value.name}</small>
      `);
      if (value.directMessagesEnabled === "false") {
        $(element).addClass("disabled");
        $(element).append(`<small>${$searchInput.data().directMessagesDisabled}</small>`);
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
      <li tabindex="-1">
        <input type="hidden" name="${options.name}" value="${id}">
        <img src="${selection.value.avatarUrl}" alt="${selection.value.name}">
        <span>${selection.value.name}</span>
        <button type="button" data-remove="${id}" tabindex="0" aria-controls="0" aria-label="${label}">${icon("delete-bin-line")}</button>
      </li>
    `);

    autoComplete.setInput("");
    selected.push(id);
    updateSubmitButton($fieldContainer, $selectedItems);

    $selectedItems.find(`*[data-remove="${id}"]`).on("keypress click", (evt) => {
      const target = evt.currentTarget.parentNode;
      if (target.tagName === "LI") {
        const focusElement = target.nextElementSibling || target.previousElementSibling || emptyFocusElement;

        selected = selected.filter((identifier) => identifier !== id);
        target.remove();

        updateSubmitButton($fieldContainer, $selectedItems);
        focusElement.focus();
      }
    })
  })
})
