document.addEventListener("decidim:loaded", () => {
  document.querySelectorAll('[data-action="csv_census-record"]').forEach((button) => {
    const url = button.dataset.censusUrl;
    const drawer = window.Decidim.currentDialogs[button.dataset.censusDialog];
    const container = drawer.dialog.querySelector("#csv-census-actions");

    const fetchUrl = (urlToFetch) => {
      container.classList.add("spinner-container");
      fetch(urlToFetch).then((response) => response.text()).then((html) => {
        container.innerHTML = html;

        container.classList.remove("spinner-container");
        // We still need foundation for form validations
        $(container).foundation();
      });
    };

    button.addEventListener("click", () => {
      fetchUrl(url);
      drawer.open();
    });
  })
});
