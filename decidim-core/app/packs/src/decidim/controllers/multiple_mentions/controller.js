import { Controller } from "@hotwired/stimulus"
import AutoComplete from "src/decidim/autocomplete";
import icon from "src/decidim/icon";

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
    this.searchInput.addEventListener("selection", (event) => {
      const feedback = event.detail;
      const selection = feedback.selection;
      this.handleSelection(selection);
    });
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
    this.autoComplete = new AutoComplete(this.searchInput, {
      dataMatchKeys: ["name", "nickname"],
      dataSource: this.getDataSource.bind(this),
      dataFilter: this.filterResults.bind(this),
      modifyResult: this.modifyResult.bind(this)
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
      (item) => !this.selected.includes(item.value.id)
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
    // Check if we have reached the maximum limit or if direct messages are disabled
    if (this.isMaxLimitReached() || selection.value.directMessagesEnabled === "false") {
      return;
    }

    this.addSelectedUser(selection, id);
    this.autoComplete.setInput("");
    this.selected.push(id);
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
      <input type="hidden" name="${this.options.name}" value="${id}">
      <img src="${selection.value.avatarUrl}" alt="${selection.value.name}">
      <span>${selection.value.name}</span>
      <button type="button" data-remove="${id}" tabindex="0" aria-controls="0" aria-label="${label}">${icon("delete-bin-line")}</button>
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
