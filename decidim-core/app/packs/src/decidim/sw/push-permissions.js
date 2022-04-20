window.addEventListener("DOMContentLoaded", async () => {
  if ("serviceWorker" in navigator) {
    const toggle = document.getElementById("allow_push_notifications")

    if (toggle) {
      const reminder = document.querySelector("#push-notifications-reminder")
      const HIDE_CLASS = "hide"

      const subKeys = JSON.parse(document.querySelector("#subKeys").value)

      const registration = await navigator.serviceWorker.ready
      const currentSubscription = await registration.pushManager.getSubscription()

      if (currentSubscription) {
        const auth = currentSubscription.toJSON().keys.auth
        // Subscribed && browser notif enabled
        if (subKeys.includes(auth) && (window.Notification.permission === "granted")) {
          reminder.classList.add(HIDE_CLASS)
          toggle.checked = true
        }
        // Not Subscribed && browser notif enabled
        else if (!subKeys.includes(auth) && (window.Notification.permission === "granted")) {
          reminder.classList.add(HIDE_CLASS)
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
            reminder.classList.add(HIDE_CLASS)
          } else {
            throw new Error("Permission not granted for Notification");
          }
        }
        else {
          /* eslint-disable no-shadow */
          const currentSubscription = await registration.pushManager.getSubscription()
          const auth = currentSubscription.toJSON().keys.auth
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
          reminder.classList.add(HIDE_CLASS)
        } else {
          toggle.checked = false
        }
      }
    }
  }
});
