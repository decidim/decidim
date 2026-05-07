document.addEventListener("turbo:load", async () => {
  const GRANTED_PERMISSION = "granted"

  const hideReminder = function() {
    const reminder = document.querySelector("#push-notifications-reminder")
    reminder.classList.add("hide")
  }

  const showError = (message) => {
    const container = document.querySelector(".push-notifications")
    if (!container) return

    const existingError = container.querySelector(".push-notifications__error")
    if (existingError) {
      existingError.remove()
    }

    const errorElement = document.createElement("div")
    errorElement.classList.add("flash", "alert", "push-notifications__error")
    errorElement.innerText = message
    container.prepend(errorElement)
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
          const response = await fetch("/notifications_subscriptions", {
            headers: {
              "Content-Type": "application/json",
              "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content
            },
            method: "POST",
            body: JSON.stringify(subscription)
          });

          if (!response.ok) {
            const body = await response.json()
            throw new Error(body.error)
          }
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
        try {
          if (target.checked) {
            await subscribeToNotifications(registration)
          } else {
            await unsubscribeFromNotifications(registration)
          }
        } catch (error) {
          target.checked = false
          showError(error.message)
        }
      })
    }
  }
});
