document.addEventListener("decidim:loaded", () => {
  document.querySelectorAll(".js-taxonomy-filters-container").forEach((container) => {
    const name = container.dataset.name;
    const indexUrl = container.dataset.indexUrl;
    const showUrl = container.dataset.showUrl;
    const drawer = window.Decidim.currentDialogs[`${name}-dialog`];

    const activateSelects = () => {
      const taxonomySelector = container.querySelector(".js-drawer-taxonomy-select select");
      const filterSelector = container.querySelector(".js-drawer-filter-select select");

      if(taxonomySelector) { 
        taxonomySelector.addEventListener("change", (event) => {
          const taxonomyId = event.target.value;
          fetchUrl(showUrl.replace('_ID_', taxonomyId));
        });
      }

      if(filterSelector) {
        filterSelector.addEventListener("change", (event) => {
          const filterId = event.target.value;
          const taxonomyId = taxonomySelector.value;
          fetchUrl(showUrl.replace('_ID_', taxonomyId).replace('_FILTER_ID_', filterId));
        });
      }
    };

    const fetchUrl = (url) => {
      container.classList.add("spinner-container");
      console.log(url)
      fetch(url).then((response) => response.text()).then((html) => {
        container.innerHTML = html;
        container.classList.remove("spinner-container");
        activateSelects();
      });
    };

    drawer.dialog.addEventListener("open.dialog", () => {
      fetchUrl(indexUrl);
    });
  });
});