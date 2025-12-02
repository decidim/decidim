document.addEventListener("turbo:load", () => {
  const checkbox = document.querySelector(".census-check-toggle");

  if (!checkbox) {
    return;
  }

  checkbox.addEventListener("change", () => {
    const url = checkbox.dataset.url;
    const checked = checkbox.checked;
    const csrfToken = document.querySelector("meta[name='csrf-token']");

    if (!csrfToken) {
      console.error("CSRF token not found. Please refresh the page.");
      checkbox.checked = !checked;
      return;
    }

    fetch(url, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken.content
      },
      body: JSON.stringify({
        // eslint-disable-next-line camelcase
        allow_census_check_before_start: checked
      })
    }).then((response) => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    }).then((data) => {
      if (!data.success) {
        checkbox.checked = !checked;
        console.error(`Error updating setting: ${data.error || "Unknown error"}`);
      }
    }).catch((error) => {
      checkbox.checked = !checked;
      console.error(`Error updating setting: ${error.message}`);
    });
  });
});
