/**
 * This file handles the interactions of actions in notifications (if any)
 * @param {HTMLElement} node target node
 * @returns {void}
 */
export default function(node = document) {
  const actions = node.querySelectorAll("[data-notification-action]")
  if (!actions.length) {
    return;
  }

  const extractMessage = (detail) => {
    return detail && detail.message || detail[0] && detail[0].message
  };

  const resolvePanel = (panel, message, klass) => {
    panel.classList.remove("spinner-container");
    if (message) {
      panel.innerHTML = `<div class="callout ${klass}">${message}</div>`;
    } else {
      panel.innerHTML = "";
    }
  };

  actions.forEach((action) => {
    const panel = action.closest(".notification__snippet-actions")
    action.addEventListener("ajax:beforeSend", () => {
      panel.classList.add("spinner-container");
      panel.querySelectorAll("[data-notification-action]").forEach((el) => {
        el.disabled = true;
      });
    });
    action.addEventListener("ajax:success", (event) => {
      resolvePanel(panel, extractMessage(event.detail), "success");
    });
    action.addEventListener("ajax:error", (event) => {
      resolvePanel(panel, extractMessage(event.detail) || window.Decidim.config.get("notifications").action_error, "alert");
    });
  });
}
