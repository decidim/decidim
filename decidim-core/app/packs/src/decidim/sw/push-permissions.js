window.addEventListener("DOMContentLoaded", async () => {
  const GRANTED_PERMISSION = "granted"

  const hideReminder = function() {
    const reminder = document.querySelector("#push-notifications-reminder")
    reminder.classList.add("hide")
  }

  const subscribeToNotifications = async (registration) => {
    const permission = await window.Notification.requestPermission();

    if (registration && permission === GRANTED_PERMISSION) {
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
              "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content
            },
            method: "POST",
            body: JSON.stringify(subscription)
          });
        }
      }
      hideReminder()
    } else {
      throw new Error("Permission not granted for Notification");
    }
  }

  const unsubscribeFromNotifications = async (registration) => {
    /* eslint-disable no-shadow */
    const currentSubscription = await registration.pushManager.getSubscription()
    const auth = currentSubscription.toJSON().keys.auth
    await fetch(`/notifications_subscriptions/${auth}`, {
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content
      },
      method: "DELETE"
    });
  }

  const setToggleState = async (registration, toggle) => {
    const currentSubscription = await registration.pushManager.getSubscription()
    let toggleChecked = false

    if (window.Notification.permission === GRANTED_PERMISSION) {
      hideReminder()
      if (currentSubscription) {
        const auth = currentSubscription.toJSON().keys.auth
        const subKeys = JSON.parse(document.querySelector("#subKeys").value)
        // Subscribed && browser notifications enabled
        if (subKeys.includes(auth)) {
          toggleChecked = true
        }
      }
    }
    toggle.checked = toggleChecked
  }

  if ("serviceWorker" in navigator) {
    const toggle = document.getElementById("allow_push_notifications")

    if (toggle) {
      const registration = await navigator.serviceWorker.ready

      setToggleState(registration, toggle)

      toggle.addEventListener("change", async ({ target }) => {
        if (target.checked) {
          await subscribeToNotifications(registration);
        } else {
          await unsubscribeFromNotifications(registration)
        }
      })
    }
  }
});
