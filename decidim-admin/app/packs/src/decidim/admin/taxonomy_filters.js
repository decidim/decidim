/* eslint-disable no-use-before-define */
document.addEventListener("decidim:loaded", () => {
  document.querySelectorAll(".js-taxonomy-filters-container").forEach((settingsContainer) => {
    const drawer = window.Decidim.currentDialogs[settingsContainer.dataset.drawer];
    const container = drawer.dialog.querySelector(".js-taxonomy-filters-drawer-container");
    const addButton = settingsContainer.querySelector(".js-add-taxonomy-filter");

    // Handles the click on edit button for each taxonomy filter in the component settings table
    const activateSettingsActions = () => {
      const edits = settingsContainer.querySelectorAll(".js-edit-taxonomy-filter");
      edits.forEach((edit) => {
        edit.addEventListener("click", (event) => {
          event.preventDefault();
          drawer.open();
          fetchUrl(edit.href);
        });
      });
    };

    // Handles the change on the taxonomy and filter selects in the drawer
    const activateDrawerActions = () => {
      const taxonomySelector = container.querySelector(".js-drawer-taxonomy-select select");
      const filterSelector = container.querySelector(".js-drawer-filter-select select");
      const selectForm = drawer.dialog.querySelector("#select-taxonomy-filter-form");
      const saveForm = drawer.dialog.querySelector("#save-taxonomy-filter-form");
      const save = drawer.dialog.querySelector("#save-taxonomy-filter");
      const remove = drawer.dialog.querySelector("#remove-taxonomy-filter");
      const currentFilters = settingsContainer.querySelector(".js-current-filters");

      if (selectForm) {
        selectForm.addEventListener("ajax:success", (event) => {
          container.innerHTML = event.detail[2].responseText;
          activateDrawerActions();
        });
      }

      if (remove) {
        remove.addEventListener("ajax:success", (event) => {
          currentFilters.innerHTML = event.detail[2].responseText;
          activateSettingsActions();
          drawer.close();
        });
      }

      if (taxonomySelector) {
        taxonomySelector.addEventListener("change", () => {
          Rails.fire(selectForm, "submit");
        });
      }

      if (filterSelector) {
        filterSelector.addEventListener("change", () => {
          Rails.fire(selectForm, "submit");
        });
      }

      if (saveForm) {
        saveForm.addEventListener("ajax:success", (event) => {
          currentFilters.innerHTML = event.detail[2].responseText;
          activateSettingsActions();
          drawer.close();
        });

        if (save) {
          save.addEventListener("click", (event) => {
            event.preventDefault();
            Rails.fire(saveForm, "submit");
          });
        }
      }
    };

    const fetchUrl = (url) => {
      container.classList.add("spinner-container");
      fetch(url).then((response) => response.text()).then((html) => {
        container.innerHTML = html;
        container.classList.remove("spinner-container");
        activateDrawerActions();
      });
    };

    // Activate the rendered edit buttons
    activateSettingsActions();

    // Opens the drawer with the form to add a new taxonomy filter
    addButton.addEventListener("click", (event) => {
      event.preventDefault();
      const url = addButton.dataset.url;
      fetchUrl(url);
      drawer.open();
    });
  });
});
