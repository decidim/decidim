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

  const updateNotification = (action) => {
    const panel = action.closest(".notification__snippet-actions")
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
  };

  actions.forEach((action) => {
    const panel = action.closest(".notification__snippet-actions")
    action.addEventListener("ajax:beforeSend", (event) => {
      console.log("ajax:beforeSend", event)
      event.detail[0].onreadystatechange = function() {
        if (this.readyState === this.DONE) {
            console.log("DONE", this.responseURL, this)
            this.abort() // This seems to stop the response
            updateNotification(action);
        }
      };
      panel.classList.add("spinner-container");
      panel.querySelectorAll("[data-notification-action]").forEach((el) => {
        el.disabled = true;
      });
    });
    action.addEventListener("ajax:success", () => {
      console.log("ajax:success")
    });
    action.addEventListener("ajax:abort", () => {
      console.log("ajax:abort")
    });
    action.addEventListener("ajax:error", () => {
      console.log("ajax:error")
    });
    action.addEventListener("ajax:complete", () => {
      console.log("ajax:complete")
    });
  });
}
