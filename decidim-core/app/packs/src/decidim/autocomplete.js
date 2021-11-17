import AutoCompleteJS from "@tarekraafat/autocomplete.js";

export default class AutoComplete {

  /**
   * This method can be used to create an autocomplete input automatically
   * from the following kind of div:
   *   <div data-autocomplete="{...}"></div>
   *
   * The data-autocomplete attribute should contain the following configuration
   * which is used to generate the AutoComplete options:
   * - name: assembly_member[user_id],
   * - options: [],
   * - placeholder: "Select a participant",
   * - searchPromptText: "Type at least three characters to search"
   * - noResultsText: "No results found"
   * - searchURL: "http://..."
   * - changeURL: null,
   * - selected: "",
   *
   * @param {HTMLElement} el The element to generate the autocomplete for.
   * @returns {AutoComplete} An instance of the AutoComplete class.
   */
  static autoConfigure(el) {
    const config = JSON.parse(el.dataset.autocomplete);
    const input = document.createElement("input");
    input.name = config.name;
    input.type = "hidden";

    const textInput = document.createElement("input");
    input.name = config.name;
    textInput.type = "text";

    const selectedValue = document.createElement("span");
    selectedValue.className = "selected-value";
    selectedValue.style.display = "none";

    const clearSelection = document.createElement("span");
    clearSelection.className = "clear-selection";
    clearSelection.innerHTML = "&times;";
    clearSelection.style.display = "none";

    if (config.placeholder) {
      textInput.placeholder = config.placeholder;
    }
    if (config.selected) {
      input.value = config.selected.value;
      textInput.value = config.selected.label;
    }
    el.parentNode.insertBefore(textInput, el.nextSibling);
    el.parentNode.insertBefore(input, textInput);

    const dataSource = (query, callback) => {
      const params = new URLSearchParams({ term: query });
      fetch(`${config.searchURL}?${params.toString()}`, {
        method: "GET",
        headers: { "Content-Type": "application/json" }
      }).then((response) => response.json()).then((data) => {
        callback(data)
      });
    };

    const ac = new AutoComplete(textInput, {
      dataMatchKeys: ["label"],
      dataSource
    });

    const wrapper = document.querySelector(".autoComplete_wrapper");
    wrapper.insertBefore(clearSelection, textInput);
    wrapper.insertBefore(selectedValue, textInput);


    const clearSelected = () => {
      input.value = ""
      textInput.placeholder = config.placeholder;
      clearSelection.style.display = "none";
      selectedValue.style.display = "none";
    }

    clearSelection.addEventListener("click", () => {
      clearSelected();
    })

    textInput.addEventListener("selection", (event) => {
      console.log("selection")
      const feedback = event.detail;
      const selection = feedback.selection;
      input.value = selection.value.value;
      textInput.value = "";
      textInput.placeholder = "";
      selectedValue.innerHTML = selection.value.label;
      selectedValue.style.display = "block";
      clearSelection.style.display = "block";
    });

    textInput.addEventListener("keyup", (event) => {
      if (input.value !== "" && (textInput.value.length > 1 || ["Escape", "Backspace"].includes(event.key))) {
        clearSelected();
      }
    })

    return ac;
  }

  constructor(el, options = {}) {
    this.element = el;
    this.options = Object.assign({
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

    const threshold = this.options?.threshold || 2;
    this.autocomplete = new AutoCompleteJS({
      selector: () => this.element,
      // Delay (milliseconds) before autocomplete engine starts
      debounce: 200,
      threshold: threshold,
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
    this.element.dataset.autocomplete = this.autocomplete;
  }

  setInput(value) {
    this.autocomplete.input.value = value;
  }
}
