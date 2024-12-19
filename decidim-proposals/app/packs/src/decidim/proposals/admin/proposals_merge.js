document.addEventListener("decidim:loaded", () => {
  document.querySelectorAll('button[data-action="merge-proposals"]').forEach((button) => {
    const url = button.dataset.mergeUrl;
    // console.log("found!", button, url);
    const drawer = window.Decidim.currentDialogs[button.dataset.mergeDialog];
    const container = drawer.dialog.querySelector(".js-bulk-action-form");

    const fetchUrl = (url) => {
      container.classList.add("spinner-container");
      fetch(url).then((response) => response.text()).then((html) => {
        container.innerHTML = html;
        container.classList.remove("spinner-container");
        // activateDrawerActions();
      });
    };

    button.addEventListener("click", (event) => {
      const selectedProposals = Array.from(document.querySelectorAll(".js-check-all-proposal:checked")).map((checkbox) => checkbox.value);
      const uniqueProposals = [...new Set(selectedProposals)];

      const queryParams = uniqueProposals.map((id) => `proposal_ids[]=${encodeURIComponent(id)}`).join("&")
      // console.log(`${url}?${queryParams}`);
      fetchUrl(`${url}?${queryParams}`);
      drawer.open();
    });
  })
});
