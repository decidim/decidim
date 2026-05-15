document.addEventListener("decidim:loaded", () => {
  document.querySelectorAll('[data-action="csv_census-record"]').forEach((button) => {
    const url = button.dataset.censusUrl;
    const drawer = window.Decidim.currentDialogs[button.dataset.censusDialog];
    const container = drawer.dialog.querySelector("#csv-census-actions");

    // Handles changes on the form
    const activateDrawerForm = () => {
      const saveForm = drawer.dialog.querySelector(".form_census_record");
      // Handles form errors and success
      if (saveForm) {
        saveForm.addEventListener("ajax:success", (event) => {
          const response = event.detail[0];

          if (response.status === "ok") {
            window.location.reload();
          } else {
            window.location.href = response.redirect_url;
          }
        });

        saveForm.addEventListener("ajax:error", (event) => {
          const response = event.detail[2];
          container.innerHTML = response.responseText;
          activateDrawerForm();
        });
      }
    }

    const fetchUrl = (urlToFetch) => {
      container.classList.add("spinner-container");
      fetch(urlToFetch).then((response) => response.text()).then((html) => {
        container.innerHTML = html;

        container.classList.remove("spinner-container");
        // We still need foundation for form validations
        $(container).foundation();
        activateDrawerForm()
      });
    };

    button.addEventListener("click", () => {
      fetchUrl(url);
      drawer.open();
    });
  })
});
