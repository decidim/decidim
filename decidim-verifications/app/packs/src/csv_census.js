document.addEventListener("decidim:loaded", () => {
  document.querySelectorAll('[data-action="csvcensus-record"]').forEach((button) => {
    const url = button.dataset.csvcensusUrl;
    const drawer = window.Decidim.currentDialogs[button.dataset.csvcensusDialog];
    const container = drawer.dialog.querySelector("#csv-census-actions");

    const fetchUrl = (urlToFetch) => {
        container.classList.add("spinner-container");
        fetch(urlToFetch).then((response) => response.text()).then((html) => {
          container.innerHTML = html;
          console.log("contenedor", container.innerHTML);
          
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