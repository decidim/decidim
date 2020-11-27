/* eslint-disable no-empty */

(() => {
  document.querySelectorAll(".clipboard-copy").forEach((shareButton) => {
    shareButton.addEventListener("click", (event) => {
      event.preventDefault();
      const el = document.createElement("textarea");
      el.value = shareButton.dataset.url;
      document.body.appendChild(el);
      el.select();
      document.execCommand("copy");
      document.body.removeChild(el);
    })
  })
})();
