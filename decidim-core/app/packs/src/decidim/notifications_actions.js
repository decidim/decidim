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
    return detail && detail.message || detail[0] && detail[0].message || detail[2] && detail[2].responseText || detail[0] || detail || "unknown error";
  };

  const resolvePanel = (panel, detail, klass) => {
    const message = extractMessage(detail);
    panel.innerHTML = `<div class="callout ${klass}">${message}</div>`;
    panel.classList.remove("spinner-container");
  };

  const updateNotification = (action, panel, detail) => {
    fetch(action.dataset.notificationAfterAction, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]") && document.querySelector("meta[name=csrf-token]").content
      },
      body: JSON.stringify({
        notification: {
          id: action.dataset.notificationId,
          action: action.dataset.notificationAction,
          message: extractMessage(detail)
        }
      })
    }).then((response) => {
      response.json().then((data) => {
        if (response.ok) {
          resolvePanel(panel, data, "success");
        } else {
          resolvePanel(panel, data, "alert");
        }
      });
    });
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
      updateNotification(action, panel, event.detail);
    });
    action.addEventListener("ajax:error", (event) => {
      resolvePanel(panel, event.detail, "alert");

    });
  });
}
