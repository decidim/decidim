window.addEventListener("DOMContentLoaded", async () => {
  if ("serviceWorker" in navigator) {
    const toggle = document.getElementById("allow_push_notifications")

    if (toggle) {
      const reminder = document.querySelector(".push-notifications__reminder")
      const hideClass = "hide"

      const subKeys = JSON.parse(document.querySelector("#subKeys").value)

      const registration = await navigator.serviceWorker.ready
      let existingSubscription = await registration.pushManager.getSubscription()

      if (existingSubscription) {
        const auth = existingSubscription.toJSON().keys.auth
        // Subscribed && browser notif enabled
        if (subKeys.includes(auth) && (window.Notification.permission === "granted")) {
          reminder.classList.add(hideClass)
          toggle.checked = true
        }
        // Not Subscribed && browser notif enabled
        else if (!subKeys.includes(auth) && (window.Notification.permission === "granted")) {
          reminder.classList.add(hideClass)
          toggle.checked = false
        }
        else {
          toggle.checked = false
        }
      }

      toggle.addEventListener("change", async ({ target }) => {
        if (target.checked) {
          const permission = await window.Notification.requestPermission();

          if (registration && permission === "granted") {
            const vapidElement = document.querySelector("#vapidPublicKey")
            // element could not exist in DOM
            if (vapidElement) {
              const vapidPublicKeyElement = JSON.parse(vapidElement.value)
              const subscription = await registration.pushManager.subscribe({
                userVisibleOnly: true,
                applicationServerKey: new Uint8Array(vapidPublicKeyElement)
              });

              if (subscription) {
                await fetch("/notifications_subscriptions", {
                  headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content
                  },
                  method: "POST",
                  body: JSON.stringify(subscription)
                });
              }
            }
            reminder.classList.add(hideClass)
          } else {
            throw new Error("Permission not granted for Notification");
          }
        }
        else {
          existingSubscription = await registration.pushManager.getSubscription()
          const auth = existingSubscription.toJSON().keys.auth
          await fetch(`/notifications_subscriptions/${auth}`, {
            headers: {
              "Content-Type": "application/json",
              "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content
            },
            method: "DELETE"
          });
        }
      })

      if (toggle.checked) {
        if (window.Notification.permission === "granted") {
          reminder.classList.add(hideClass)
        } else {
          toggle.checked = false
        }
      }
    }
  }
});
