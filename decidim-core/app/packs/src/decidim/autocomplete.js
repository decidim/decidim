/* eslint max-lines: ["error", {"max": 350}] */

import AutoCompleteJS from "@tarekraafat/autocomplete.js";
// Styles from node_modules/@tarekraafat/autocomplete.js
// It needs to be done in JS because postcss-import doesn't find files in node_modules/
import "@tarekraafat/autocomplete.js/dist/css/autoComplete.02.css";

export default class AutoComplete {
  constructor(el, options = {}) {
    this.element = el;
    this.stickySelectedSpan = null;
    this.clearStickySelectionSpan = null;
    this.stickyHiddenInput = null;
    this.promptDiv = null;
    const thresholdTemp = options.threshold || 2;
    this.options = Object.assign({
      // Defines name of the hidden input (e.g. assembly_member[user_id])
      name: null,
      // Placeholder of the visible input field
      placeholder: "",
      // Defines what happens after user has selected value from suggestions
      // sticky - Allows selecting a single value and not editing the value after selected (e.g. as the admin autocomplete fields)
      // single - Allows selecting a single value and editing the selected text after the selection (e.g. geocoding field)
      // multi - Allows selecting multiple values
      // null (default) - Disable selection event handling in this class
      mode: null,
      // Defines if we show input help (e.g. "Type at least three characters to search") or not.
      searchPrompt: false,
      // Defines search prompt message, only shown if showPrompt is enabled!
      searchPromptText: `Type at least ${thresholdTemp} characters to search`,
      // Defines items that are selected already when page is loaded before user selects them. (e.g. when form submit fails)
      selected: null,
      // Defines how many characters input has to have before we start searching
      threshold: thresholdTemp,
      // Defines how many results to show in the autocomplete selection list
      // by maximum.
      maxResults: 10,
      // Defines the data keys against which to match the user input when
      // searching through the results. For example, when the following
      // data is returned by the API:
      //   { id: 123, name: "John", nickname: "john", __typename: "User" }
      //
      // You can define the data keys array as ["name", "nickname"] in
      // which case the results shown to user would be only those that
      // have matching text in these defined fields.
      dataMatchKeys: null,
      // The data source is a method that gets the callback parameter as
      // its first argument which should be called with the results array
      // once they are returned by the API.
      // For example:
      //   (query, callback) => {
      //     (async () => {
      //       const results = await callAjax(`/api/url?query=${query}`);
      //       callback(results);
      //     })();
      //   }
      //
      // Signature: (callback: Function)
      dataSource: () => [],
      // Filters the data list returned by the data source before it is shown
      // to the user. Can be used e.g. to hide already selected values from
      // the list.
      dataFilter: null,
      // Delay in milliseconds how long to wait after user action before
      // doing a backend request.
      delay: 200,
      // Allows modifying the suggested items before they are displayed in the list
      // Signature: (element: HTMLElement, value: Object)
      modifyResult: null
    }, options);

    this.autocomplete = new AutoCompleteJS({
      selector: () => this.element,
      placeHolder: options.placeholder,
      // Delay (milliseconds) before autocomplete engine starts. It's preventing many queries when user is typing fast.
      debounce: 200,
      threshold: this.options.threshold,
      data: {
        keys: this.options.dataMatchKeys,
        src: async (query) => {
          const fetchResults = () => {
            return new Promise((resolve) => {
              this.options.dataSource(query, resolve);
            });
          }

          try {
            return await fetchResults();
          } catch (error) {
            return error;
          }
        },
        filter: (list) => {
          if (this.options.dataFilter) {
            return this.options.dataFilter(list);
          }

          return list;
        }
      },
      resultsList: {
        maxResults: this.options.maxResults
      },
      resultItem: {
        element: (item, data) => {
          if (!this.options.modifyResult) {
            return;
          }

          this.options.modifyResult(item, data.value);
        }
      },
      events: {
        input: {
          blur: () => {
            this.promptDiv.style.display = "none";
          }
        }
      }
    });

    this.acWrapper = this.element.closest(".autoComplete_wrapper");
    this.element.ac = this.autocomplete;

    // Stop input field from bubbling open and close events to parent elements,
    // because foundation closes modal from these events.
    const stopPropagation = (event) => {
      event.stopPropagation();
    }
    this.element.addEventListener("close", stopPropagation);
    this.element.addEventListener("open", stopPropagation);

    this.createPromptDiv();

    switch (this.options.mode) {
    case "sticky":
      this.createStickySelect(this.options.name);
      break;
    case "multi":
      this.createMultiSelect(this.options.name);
      break;
    default:
    }
  }

  setInput(value) {
    this.autocomplete.input.value = value;
  }

  handleEvent(event) {
    switch (this.options.mode) {
    case "single":
      this.setInput(event.detail.selection.value[event.detail.selection.key]);
      break;
    case "sticky":
      this.handleStickyEvents(event);
      break;
    case "multi":
      this.handleMultiEvents(event);
      break;
    default:
    }
  }

  handleMultiEvents(event) {
    switch (event.type) {
    case "selection":
      this.addMultiSelectItem(event.detail.selection);
      break;
    default:
    }
  }

  handleStickyEvents(event) {
    switch (event.type) {
    case "selection":
      this.addStickySelectItem(event.detail.selection);
      break;
    case "click":
      if (event.target === this.clearStickySelectionSpan) {
        this.removeStickySelection();
      }
      break;
    case "keyup":
      if (this.stickyHiddenInput.value !== "" && event.target === this.element && (["Escape", "Backspace", "Delete"].includes(event.key) || (/^[a-z0-9]$/i).test(event.key))) {
        this.removeStickySelection();
      } else if (this.options.searchPrompt) {
        if (this.stickyHiddenInput.value === "" && this.element.value.length < this.options.threshold) {
          this.promptDiv.style.display = "block";
        } else {
          this.promptDiv.style.display = "none";
        }
      }
      break;
    default:
    }
  }

  createHiddenInput(value) {
    const hiddenInput = document.createElement("input");
    hiddenInput.name = this.options.name;
    hiddenInput.type = "hidden";
    if (value) {
      hiddenInput.value = value;
    }
    this.acWrapper.prepend(hiddenInput);
    return hiddenInput;
  }

  removeStickySelection() {
    this.stickyHiddenInput.value = "";
    this.element.placeholder = this.options.placeholder;
    this.clearStickySelectionSpan.style.display = "none";
    this.stickySelectedSpan.style.display = "none";
  }

  addStickySelectItem(selection) {
    this.stickyHiddenInput.value = selection.value.value;
    this.element.placeholder = "";
    this.stickySelectedSpan.innerHTML = selection.value[selection.key];
    this.stickySelectedSpan.style.display = "block";
    this.clearStickySelectionSpan.style.display = "block";
    this.setInput("");
  }

  addMultiSelectItem(selection) {
    this.setInput("");
    const chosen = document.createElement("span");
    chosen.classList.add("label", "primary", "autocomplete__selected-item", "multi");
    chosen.innerHTML = selection.value[selection.key];
    const clearSelection = document.createElement("span");
    clearSelection.classList.add("clear-multi-selection");
    clearSelection.innerHTML = "&times;";
    clearSelection.setAttribute("data-remove", selection.value.value);
    clearSelection.addEventListener("click", (evt) => {
      const hiddenInput = this.acWrapper.querySelector(`input[type='hidden'][value='${selection.value.value}']`);
      if (hiddenInput) {
        hiddenInput.remove();
        evt.target.parentElement.remove();
      }
    });
    chosen.appendChild(clearSelection);

    const multiSelectWrapper = this.acWrapper.querySelector(".multiselect");
    const inputContainer = multiSelectWrapper.querySelector("span.input-container");
    multiSelectWrapper.insertBefore(chosen, inputContainer);
    this.createHiddenInput(selection.value.value);
  }

  createStickySelect() {
    this.stickySelectedSpan = document.createElement("span");
    this.stickySelectedSpan.classList.add("autocomplete__selected-item", "sticky");
    this.stickySelectedSpan.style.display = "none";
    this.stickySelectedSpan.addEventListener("click", () => this.element.focus());
    this.stickyHiddenInput = this.createHiddenInput();

    this.clearStickySelectionSpan = document.createElement("span");
    this.clearStickySelectionSpan.className = "clear-sticky-selection";
    this.clearStickySelectionSpan.innerHTML = "&times;";
    this.clearStickySelectionSpan.style.display = "none";
    this.clearStickySelectionSpan.addEventListener("click", this);

    this.element.addEventListener("selection", this);
    this.element.addEventListener("keyup", this);

    this.acWrapper.insertBefore(this.clearStickySelectionSpan, this.element);
    this.acWrapper.insertBefore(this.stickySelectedSpan, this.element);
    if (this.options.selected) {
      this.addStickySelectItem(this.options.selected);
    }
  }

  createMultiSelect() {
    const multiSelectWrapper = document.createElement("div");
    multiSelectWrapper.classList.add("multiselect");

    const inputContainer = document.createElement("span");
    inputContainer.classList.add("input-container");

    multiSelectWrapper.appendChild(inputContainer);
    this.acWrapper.prepend(multiSelectWrapper);
    inputContainer.appendChild(this.element);

    this.element.addEventListener("selection", this);
    multiSelectWrapper.addEventListener("click", () => {
      this.element.focus();
    })

    if (this.options.selected) {
      this.options.selected.forEach((selection) => {
        this.addMultiSelectItem(selection);
      })
    }
  }

  createPromptDiv() {
    this.promptDiv = document.createElement("div");
    this.promptDiv.classList.add("search-prompt");
    this.promptDiv.style.display = "none";
    this.promptDiv.innerHTML = this.options.searchPromptText;
    this.acWrapper.appendChild(this.promptDiv);
  }
}
