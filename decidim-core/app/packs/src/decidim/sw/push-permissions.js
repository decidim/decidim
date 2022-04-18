window.addEventListener("DOMContentLoaded", async () => {
  if ("serviceWorker" in navigator) {
    const toggle = document.getElementById("user_allow_push_notifications")

    if (toggle) {
      const reminder = document.querySelector(".push-notifications__reminder")
      const hideClass = "hide"

      toggle.addEventListener("change", async ({ target }) => {
        if (target.checked) {
          const permission = await window.Notification.requestPermission();
          const registration = await navigator.serviceWorker.ready

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
          const registration = await navigator.serviceWorker.ready
          const subscription = await registration.pushManager.getSubscription()
          const auth = subscription.toJSON().keys.auth
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
