/**
 * REDESIGN_PENDING: This file will be unnecessary once Turbo is implemented.
 * The topbar__notifications element has changes after redesign
 * @param {HTMLElement} node target node
 * @returns {void}
 */
export default function(node = document) {
  const noNotificationsText = node.querySelector(".empty-notifications")
  const handleRemove = ({ currentTarget }) => currentTarget.remove()
  const handleFadeOut = (element) => {
    if (element) {
      element.addEventListener("transitionend", handleRemove)
      element.style.opacity = 0
    }
  }
  const emptyNotifications = () => {
    noNotificationsText.classList.remove("hidden")
    noNotificationsText.classList.remove("hide")
    node.querySelector(".topbar__notifications")?.classList?.remove("is-active")
  }
  const handleClick = ({ currentTarget }) => {
    handleFadeOut(currentTarget.closest("[data-notification]"))
    if (!node.querySelector("[data-notification]:not([style])")) {
      emptyNotifications()
    }
  }

  const notifications = node.querySelectorAll("[data-notification]")

  if (notifications.length) {
    notifications.forEach((btn) => btn.querySelector("[data-notification-read]").addEventListener("click", handleClick))

    node.querySelector("[data-notification-read-all]").
      addEventListener(
        "click", () => {
          notifications.forEach((notification) => handleFadeOut(notification))
          emptyNotifications()
        }
      )
  }
}
