document.addEventListener("turbo:load", () => {
  const select = document.querySelector("select[name='proposals_import[origin_component_id]']");
  const container = document.getElementById("states-container");

  if (!select || !container) {
    return;
  }

  const statesUrl = select.dataset.statesUrl;

  const escapeHtml = (str) => {
    const div = document.createElement("div");
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  };

  const fetchStates = (componentId) => {
    if (!componentId) {
      container.innerHTML = "";
      container.style.display = "none";
      return;
    }

    const url = `${statesUrl}?origin_id=${componentId}`;

    fetch(url, {
      credentials: "same-origin",
      headers: { Accept: "application/json" }
    }).then((res) => {
      return res.json();
    }).then((states) => {

      if (!states.length) {
        container.innerHTML = "";
        container.style.display = "none";
        return;
      }

      const selectedStates = JSON.parse(container.dataset.selectedStates || "[]");

      const checkboxes = states.map((state) => {
        const token = escapeHtml(state.token);
        const title = escapeHtml(state.title);
        const checked = selectedStates.includes(state.token)
          ? "checked"
          : "";
        return `<div><label><input type="checkbox" name="proposals_import[states][]" value="${token}" ${checked}> ${title}</label></div>`;
      }).join("");

      container.innerHTML = `<div class="row column">${checkboxes}</div>`;

      container.style.display = "block";
    }).catch(() => {
      container.innerHTML = "";
      container.style.display = "none";
    });
  };

  select.addEventListener("change", (event) => fetchStates(event.target.value));

  if (select.value) {
    fetchStates(select.value);
  }
});
