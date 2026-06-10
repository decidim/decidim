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
  /**
   * Escape HTML characters in a string
   * @param {string} str - The string to escape
   * @returns {string} The escaped HTML string
   */
  const htmlEscape = (str) => {
    const div = document.createElement("div");
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }

  updateSubmitButton($fieldContainer, $selectedItems);
  const autoComplete = new TomSelect(this.searchInput, {
    maxItems: 1,
    valueField: "id",
    labelField: "name",
    searchField: ["name", "nickname"],
    loadThrottle: 200,
    loadingClass: "loading",
    preload: false,
    highlight: true,
    load: (query, callback) => {
      if (!query || query.length < 2) {
        callback();
        return;
      }
      this.getDataSource(query, (results) => {
        const filtered = this.filterResults(results);
        filtered.forEach((item) => {
          if (item.directMessagesEnabled === "false") {
            item.disabled = true;
          }
        });
        callback(filtered);
      });
    },
    render: {
      option: (data, escape) => {
        const isDisabled = data.directMessagesEnabled === "false";
        const className = isDisabled
          ? "disabled"
          : "";
        const disabledMsg = isDisabled
          ? `<small>${escape(this.searchInput.dataset.directMessagesDisabled)}</small>`
          : "";
        return `<div class="${className}">
            <img src="${escape(data.avatarUrl)}" alt="${escape(data.name)}">
            <span>${escape(data.nickname)}</span>
            <small>${escape(data.name)}</small>
            ${disabledMsg}
          </div>`;
      },
      "no_results": () => `<div class="no-results">${this.searchInput.dataset.noresults || ""}</div>`
    },
    onChange: (value) => {
      if (value) {
        const option = this.tomSelect.options[value];
        this.handleSelection({value: option});
        this.tomSelect.clear();
        this.tomSelect.clearOptions();
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
        <input type="hidden" name="${htmlEscape(this.options.name)}" value="${htmlEscape(id)}">
      <img src="${htmlEscape(selection.value.avatarUrl)}" alt="${htmlEscape(selection.value.name)}">
      <span>${htmlEscape(selection.value.name)}</span>
      <button type="button" data-remove="${htmlEscape(id)}" tabindex="0" aria-controls="0" aria-label="${htmlEscape(label)}">${icon("delete-bin-line")}</button>
      </li>
    `);

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
