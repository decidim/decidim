import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select/dist/cjs/tom-select.popular";
import icon from "src/decidim/refactor/moved/icon";

export default class extends Controller {
  connect() {
    this.searchInput = this.element.querySelector("input");
    this.selectedItems = this.element.parentNode.querySelector(`ul.${this.getInputDataAttribute("selected")}`);
    this.options = this.getElementData(this.element);
    this.selected = [];

    // Get messages configuration
    const allMessages = window.Decidim.config.get("messages");
    const messages = allMessages.mentionsModal || {};
    this.removeLabel = messages.removeRecipient || "Remove recipient %name%";

    this.initializeEmptyFocusElement();
    this.initializeAutoComplete();
  }

  /*
   * Remove event listener to prevent duplicates
   * @returns {void}
   */
  disconnect() {
    if (this.tomSelect) {
      this.tomSelect.destroy();
    }
  }

  /**
   * Get data attribute from input element
   * @param {string} attribute - The attribute name to retrieve
   * @returns {string} The attribute value
   */
  getInputDataAttribute(attribute) {
    return this.searchInput.dataset[attribute];
  }

  /**
   * Get all data attributes from an element
   * @param {HTMLElement} element - The element to get data from
   * @returns {Object} Object containing all data attributes
   */
  getElementData(element) {
    return { ...element.dataset };
  }

  /**
   * Initialize the empty focus element for accessibility
   * @returns {void}
   */
  initializeEmptyFocusElement() {
    let emptyFocusElement = this.element.parentNode.querySelector(".empty-list");
    if (!emptyFocusElement) {
      emptyFocusElement = document.createElement("div");
      emptyFocusElement.tabIndex = "-1";
      emptyFocusElement.className = "empty-list";
      this.element.parentNode.append(emptyFocusElement);
    }
    this.emptyFocusElement = emptyFocusElement;
  }

  /**
   * Initialize the autocomplete functionality
   * @returns {void}
   */
  initializeAutoComplete() {
    this.tomSelect = new TomSelect(this.searchInput, {
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
          this.handleSelection({ value: option });
          this.tomSelect.clear();
          this.tomSelect.clearOptions();
        }
      }
    });
  }

  /**
   * Data source function for autocomplete - performs GraphQL query to fetch users
   * @param {string} query - The search query
   * @param {Function} callback - Callback function to handle results
   * @returns {void}
   */
  async getDataSource(query, callback) {
    try {
      const response = await fetch(window.Decidim.config.get("api_path"), {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          query: `
            {
              users(filter:{wildcard:"${query}",excludeIds:[]})
                {
                  id,nickname,name,avatarUrl,__typename,...on User {
                    directMessagesEnabled
                  }
                }
            }`
        })
      });

      const data = await response.json();
      return callback(data.data.users);
    } catch (error) {
      console.error("Error fetching users:", error);
      return callback([]);
    }
  }

  /**
   * Filter function to exclude already selected users from results
   * @param {Array} list - The list of users returned from the API
   * @returns {Array} Filtered list excluding already selected users
   */
  filterResults(list) {
    return list.filter(
      (item) => !this.selected.includes(item.id)
    );
  }

  /**
   * Modify the result display in autocomplete dropdown
   * @param {HTMLElement} element - The result element to modify
   * @param {Object} value - The user data object
   * @returns {void}
   */
  modifyResult(element, value) {
    element.innerHTML = `
      <img src="${value.avatarUrl}" alt="${value.name}">
      <span>${value.nickname}</span>
      <small>${value.name}</small>
    `;

    if (value.directMessagesEnabled === "false") {
      element.classList.add("disabled");
      const disabledMessage = document.createElement("small");
      disabledMessage.textContent = this.searchInput.dataset.directMessagesDisabled;
      element.appendChild(disabledMessage);
    }
  }

  /**
   * Handle the selection of a user from autocomplete
   * @param {Object} selection - The selected user object
   * @returns {void}
   */
  handleSelection(selection) {
    const id = selection.value.id;
    if (this.isMaxLimitReached() || selection.value.directMessagesEnabled === "false") {
      return;
    }

    this.addSelectedUser(selection, id);
    this.selected.push(id);
  }

  /**
   * Escape HTML characters in a string
   * @param {string} str - The string to escape
   * @returns {string} The escaped HTML string
   */
  htmlEscape(str) {
    const div = document.createElement("div");
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }

  /**
   * Add a selected user to the display list
   * @param {Object} selection - The selected user object
   * @param {string} id - The user ID
   * @returns {void}
   */
  addSelectedUser(selection, id) {
    const label = this.removeLabel.replace("%name%", selection.value.name);

    const listItem = document.createElement("li");
    listItem.tabIndex = "-1";
    listItem.innerHTML = `
      <input type="hidden" name="${this.htmlEscape(this.options.name)}" value="${this.htmlEscape(id)}">
      <img src="${this.htmlEscape(selection.value.avatarUrl)}" alt="${this.htmlEscape(selection.value.name)}">
      <span>${this.htmlEscape(selection.value.name)}</span>
      <button type="button" data-remove="${this.htmlEscape(id)}" tabindex="0" aria-controls="0" aria-label="${this.htmlEscape(label)}">${icon("delete-bin-line")}</button>
    `;

    this.selectedItems.appendChild(listItem);

    // Attach event handler for the remove button
    const removeButton = listItem.querySelector(`[data-remove="${id}"]`);
    removeButton.addEventListener("keypress", (evt) => this.handleRemoval(evt, id));
    removeButton.addEventListener("click", (evt) => this.handleRemoval(evt, id));
  }

  /**
   * Handle the removal of a selected user
   * @param {Event} evt - The event object
   * @param {string} id - The user ID to remove
   * @returns {void}
   */
  handleRemoval(evt, id) {
    const target = evt.currentTarget.parentNode;
    if (target.tagName === "LI") {
      const focusElement = target.nextElementSibling || target.previousElementSibling || this.emptyFocusElement;

      this.selected = this.selected.filter((identifier) => identifier !== id);
      target.remove();

      focusElement.focus();
    }
  }

  /**
   * Clear all selected users
   * @returns {void}
   */
  clearSelection() {
    this.selected = [];
    this.selectedItems.innerHTML = "";
  }

  /**
   * Check if maximum selection limit is reached
   * @returns {boolean} True if maximum limit is reached
   */
  isMaxLimitReached() {
    return this.selected.length >= 9;
  }
}
