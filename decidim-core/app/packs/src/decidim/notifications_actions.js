/**
 * This file handles the interactions of actions in nofitications (if any)
 * @param {HTMLElement} node target node
 * @returns {void}
 */
export default function(node = document) {
  const actions = node.querySelectorAll("[data-notification-action]")
  if (!actions.length) {
    return;
  }
  actions.forEach((action) => {
    const panel = action.closest(".notification__snippet-actions")
    action.addEventListener("ajax:beforeSend", () => {
      panel.classList.add("spinner-container");
      panel.querySelectorAll("[data-notification-action]").forEach((el) => {
        el.disabled = true;
      });
    });
    action.addentListener("ajax:complete", () => {
      fetch(action.dataset.notificationAfterAction, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name=csrf-token]") && document.querySelector("meta[name=csrf-token]").content
        },
        body: JSON.stringify({
          notification: {
            id: action.dataset.notificationId,
            action: action.dataset.notificationAction
          }
        })
      }).then((response) => {
        response.text().then((data) => {
          panel.innerHTML = data
        });
        panel.classList.remove("spinner-container");
      });
    });
  });
}
