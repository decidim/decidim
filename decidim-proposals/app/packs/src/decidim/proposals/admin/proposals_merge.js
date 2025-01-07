import createEditor from "src/decidim/editor";
import AutoComplete from "src/decidim/autocomplete";

document.addEventListener("decidim:loaded", () => {
  document.querySelectorAll('button[data-action="merge-proposals"]').forEach((button) => {
    const url = button.dataset.mergeUrl;
    const drawer = window.Decidim.currentDialogs[button.dataset.mergeDialog];
    const container = drawer.dialog.querySelector(".js-bulk-action-form");

    // Handles autocomplete initialization
    const initializeAutoComplete = (inputElement) => {

      /**
       * Initializes autocomplete functionality for a given input element.
       *
       * @param {HTMLElement} inputElement - The input element to attach autocomplete to.
       */
      AutoComplete.init(inputElement, {
        mode: "single",
        dataMatchKeys: ["value"],
        dataSource: (query, callback) => {
          const event = new CustomEvent("geocoder-suggest.decidim", {
            detail: { query, callback }
          });
          inputElement.dispatchEvent(event);
        }
      });
    };

    // Handles geocoding_field
    const geocoding = () => {
      document.querySelectorAll("[data-decidim-geocoding]").forEach((el) => {
        if (el.dataset.geocodingInitialized) {
          return;
        }
        el.dataset.geocodingInitialized = true;
        const input = el;

        initializeAutoComplete(input);

        el.addEventListener("selection", (event) => {
          const selectedItem = event.detail.selection.value;

          const suggestSelectEvent = new CustomEvent("geocoder-suggest-select.decidim", {
            detail: selectedItem
          });
          input.dispatchEvent(suggestSelectEvent);

          // Check for coordinates in the selected item
          if (selectedItem.coordinates) {
            const coordinatesEvent = new CustomEvent("geocoder-suggest-coordinates.decidim", {
              detail: selectedItem.coordinates
            });
            input.dispatchEvent(coordinatesEvent);
          }
        });
      });
    };

    // Handles editor initialization
    const editorInitializer = () => {
      container.querySelectorAll(".editor-container").forEach((element) => createEditor(element));
    }

    // Handles the change on the form
    const activateDrawerForm = () => {
      const saveForm = drawer.dialog.querySelector("#js-form-merge-proposals");

      if (saveForm) {
        saveForm.addEventListener("ajax:success", (event) => {
          const response = event.detail[0];

          if (response.status === "ok") {
            window.location.reload();
            drawer.close();
          } else {
            window.location.href = response.redirect_url;
          }
        });

        saveForm.addEventListener("ajax:error", (event) => {
          const response = event.detail[2];
          container.innerHTML = response.responseText;

          editorInitializer();
          geocoding();
        });
      }
    }

    const fetchUrl = (urlToFetch) => {
      container.classList.add("spinner-container");
      fetch(urlToFetch).then((response) => response.text()).then((html) => {
        container.innerHTML = html;
        container.classList.remove("spinner-container");
        activateDrawerForm();
        editorInitializer()
        geocoding()
      });
    };

    button.addEventListener("click", () => {
      const selectedProposals = Array.from(document.querySelectorAll(".js-check-all-proposal:checked")).map((checkbox) => checkbox.value);
      const uniqueProposals = [...new Set(selectedProposals)];

      const queryParams = uniqueProposals.map((id) => `proposal_ids[]=${encodeURIComponent(id)}`).join("&")
      fetchUrl(`${url}?${queryParams}`);
      drawer.open();
    });
  })
});
