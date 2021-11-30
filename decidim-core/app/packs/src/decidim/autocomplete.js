import AutoCompleteJS from "@tarekraafat/autocomplete.js";

export default class AutoComplete {
  constructor(el, options = {}) {
    this.element = el;
    this.selectedValue = null;
    this.clearSelection = null;
    this.hiddenInput = null;
    this.multiSelectWrapper = null;
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

    console.log("this.options.mode", this.options.mode);
    switch (this.options.mode) {
    case "sticky":
      this.createStickySelect(this.options.name);
      break;
    case "multi":
      this.createMultiSelect(this.options.name);
      break;
    default:
    }

    this.element.ac = this.autocomplete;
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
      // Remove multiselect item
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
      if (event.target === this.clearSelection) {
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
    const acWrapper = document.querySelector(".autoComplete_wrapper");
    const hiddenInput = document.createElement("input");
    hiddenInput.name = this.options.name;
    hiddenInput.type = "hidden";
    if (value) {
      hiddenInput.value = value;
    }
    acWrapper.prepend(hiddenInput)
    return hiddenInput;
  }

  clearSelected() {
    this.hiddenInput.value = ""
    this.element.placeholder = this.options.placeholder;
    this.setInput("");
    this.clearSelection.style.display = "none";
    this.selectedValue.style.display = "none";
  }

  addStickySelectItem(selection) {
    this.hiddenInput.value = selection.value.value;
    this.setInput("");
    this.element.placeholder = "";
    this.selectedValue.innerHTML = selection.value[selection.key];
    this.selectedValue.style.display = "block";
    this.clearSelection.style.display = "block";
  }

  addMultiSelectItem(selection) {
    this.setInput("");
    const chosen = document.createElement("span");
    chosen.classList.add("label", "primary")
    chosen.innerHTML = selection.value[selection.key];
    // Check this from tags module
    chosen.setAttribute("data-remove", selection.value.value);

    const clearSelection = document.createElement("span");
    clearSelection.classList.add("remove");
    clearSelection.innerHTML = "&times;";
    clearSelection.addEventListener("click", (evt) => {
      evt.target.parentElement.remove();
    });
    chosen.appendChild(clearSelection);

    const inputContainer = this.multiSelectWrapper.querySelector("span.input-container")
    this.multiSelectWrapper.insertBefore(chosen, inputContainer);

    console.log("selection", selection)
    this.createHiddenInput(selection.value.value)
  }

  createStickySelect() {
    this.selectedValue = document.createElement("span");
    this.selectedValue.className = "selected-value";
    this.selectedValue.style.display = "none";

    this.hiddenInput = this.createHiddenInput();

    this.clearSelection = document.createElement("span");
    this.clearSelection.className = "clear-selection";
    this.clearSelection.innerHTML = "&times;";
    this.clearSelection.style.display = "none";
    this.clearSelection.addEventListener("click", this);

    const acWrapper = document.querySelector(".autoComplete_wrapper");
    acWrapper.insertBefore(this.clearSelection, this.element);
    acWrapper.insertBefore(this.selectedValue, this.element);
    this.element.addEventListener("selection", this);
  }

  createMultiSelect() {
    const acWrapper = document.querySelector(".autoComplete_wrapper");
    this.multiSelectWrapper = document.createElement("div");
    this.multiSelectWrapper.classList.add("multiselect");

    const inputContainer = document.createElement("span");
    inputContainer.classList.add("input-container")

    this.multiSelectWrapper.appendChild(inputContainer);
    acWrapper.prepend(this.multiSelectWrapper);
    inputContainer.appendChild(this.element);

    this.multiSelectWrapper.addEventListener("click", () => {
      this.element.focus();
    })

    // testi
    this.addMultiSelectItem({
      key: "label",
      value: {
        label: "testitagi",
        value: "1337"
      }
    })
  }
}
