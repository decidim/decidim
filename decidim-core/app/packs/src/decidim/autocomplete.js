import AutoCompleteJS from "@tarekraafat/autocomplete.js";

export default class AutoComplete {
  constructor(el, options = {}) {
    this.element = el;
    this.stickySelectedValue = null;
    this.clearStickySelection = null;
    this.stickyHiddenInput = null;
    this.options = Object.assign({
      // Name of the resource
      name: null,
      // Placeholder of visible input field
      placeholder: "",
      // Defines what happens after user has selected value from suggestions
      // sticky - Allows selecting a single value and not editing the value after selected (e.g. as the admin autocomplete fields)
      // single - Allows selecting a single value and editing the selected text after the selection (e.g. geocoding field)
      // multi - Allows selecting multiple values
      // null (default) - Disable selection event handling in this class
      mode: null,
      // Defines items that are selected already when page is loaded before user selects them. (e.g. when form submit fails)
      selected: null,
      // Defines how many characters input has to have before we start searching
      threshold: 2,
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
      // Allows modifying the result items before they are added to the DOM
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

          this.options.modifyResult(item, data.value)
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
    this.element.addEventListener("close", stopPropagation)
    this.element.addEventListener("open", stopPropagation)

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
    case "click":
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
      if (event.target === this.clearStickySelection) {
        this.clearSelected();
      }
      break;
    case "keyup":
      if (event.target === this.element && this.element.value !== "" && (this.element.value.length > 1 || ["Escape", "Backspace", "Delete"].includes(event.key))) {
        this.clearSelected();
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
    this.acWrapper.prepend(hiddenInput)
    return hiddenInput;
  }

  clearSelected() {
    this.stickyHiddenInput.value = ""
    this.element.placeholder = this.options.placeholder;
    this.setInput("");
    this.clearStickySelection.style.display = "none";
    this.stickySelectedValue.style.display = "none";
  }

  addStickySelectItem(selection) {
    this.stickyHiddenInput.value = selection.value.value;
    this.element.placeholder = "";
    this.stickySelectedValue.innerHTML = selection.value[selection.key];
    this.stickySelectedValue.style.display = "block";
    this.clearStickySelection.style.display = "block";
    this.setInput("");
  }

  addMultiSelectItem(selection) {
    this.setInput("");
    const chosen = document.createElement("span");
    chosen.classList.add("label", "primary", "autocomplete__selected-item")
    chosen.innerHTML = selection.value[selection.key];
    const clearSelection = document.createElement("span");
    clearSelection.classList.add("clear-selection");
    clearSelection.innerHTML = "&times;";
    clearSelection.setAttribute("data-remove", selection.value.value);
    clearSelection.addEventListener("click", (evt) => {
      const hiddenInput = this.acWrapper.querySelector(`input[type='hidden'][value='${selection.value.value}']`)
      if (hiddenInput) {
        hiddenInput.remove();
        evt.target.parentElement.remove();
      }
    });
    chosen.appendChild(clearSelection);

    const multiSelectWrapper = this.acWrapper.querySelector(".multiselect");
    const inputContainer = multiSelectWrapper.querySelector("span.input-container")
    multiSelectWrapper.insertBefore(chosen, inputContainer);
    this.createHiddenInput(selection.value.value)
  }

  createStickySelect() {
    this.stickySelectedValue = document.createElement("span");
    this.stickySelectedValue.className = "autocomplete__selected-item";
    this.stickySelectedValue.style.display = "none";

    this.stickyHiddenInput = this.createHiddenInput();

    this.clearStickySelection = document.createElement("span");
    this.clearStickySelection.className = "clear-selection";
    this.clearStickySelection.innerHTML = "&times;";
    this.clearStickySelection.style.display = "none";
    this.clearStickySelection.addEventListener("click", this);

    this.acWrapper.insertBefore(this.clearStickySelection, this.element);
    this.acWrapper.insertBefore(this.stickySelectedValue, this.element);
    this.element.addEventListener("selection", this);
    if (this.options.selected) {
      this.addStickySelectItem(this.options.selected)
    }
  }

  createMultiSelect() {
    const multiSelectWrapper = document.createElement("div");
    multiSelectWrapper.classList.add("multiselect");

    const inputContainer = document.createElement("span");
    inputContainer.classList.add("input-container")

    multiSelectWrapper.appendChild(inputContainer);
    this.acWrapper.prepend(multiSelectWrapper);
    inputContainer.appendChild(this.element);

    multiSelectWrapper.addEventListener("click", () => {
      this.element.focus();
    })

    if (this.options.selected) {
      this.options.selected.forEach((selection) => {
        this.addMultiSelectItem(selection);
      })
    }
  }
}
