document.addEventListener("turbo:load", () => {
  const select = document.querySelector("select[name='proposals_import[origin_component_id]']");
  const container = document.getElementById("states-container");

  if (!select || !container) {
    return;
  }

  const statesUrl = select.dataset.statesUrl;
  console.log("[ImportProposals] initialized, statesUrl:", statesUrl);

  select.addEventListener("change", () => {
    const componentId = select.value;
    console.log("[ImportProposals] component changed to:", componentId);

    if (!componentId) {
      container.innerHTML = "";
      container.style.display = "none";
      return;
    }

    const url = `${statesUrl}?component_id=${componentId}`;
    console.log("[ImportProposals] fetching:", url);

    fetch(url, {
      credentials: "same-origin",
      headers: { Accept: "application/json" }
    }).then((res) => {
      console.log("[ImportProposals] response status:", res.status, res.url);
      return res.json();
    }).then((states) => {
      console.log("[ImportProposals] states received:", states);

      if (!states.length) {
        container.innerHTML = "";
        container.style.display = "none";
        return;
      }

      const checkboxes = states.map((state) => `
        <div>
          <label>
            <input type="checkbox" name="proposals_import[states][]" value="${state.token}">
            ${state.title}
          </label>
        </div>
      `).join("");

      container.innerHTML = `<div class="row column">${checkboxes}</div>`;
      container.style.display = "block";
    }).catch((err) => {
      console.error("[ImportProposals] fetch error:", err);
      container.innerHTML = "";
      container.style.display = "none";
    });
  });
});
