/**
 * REDESIGN_PENDING: This file will be unnecessary once Turbo is implemented.
 * @returns {void}
 */
export default function() {
  const handleRemove = ({ currentTarget }) => currentTarget.remove()
  const handleFadeOut = (element) => {
    if (element) {
      element.addEventListener("transitionend", handleRemove)
      element.style.opacity = 0
    }
  }
  const handleClick = ({ currentTarget }) => handleFadeOut(currentTarget.closest("[data-notification]"))

  const notifications = document.querySelectorAll("[data-notification]")

  if (notifications.length) {
    notifications.forEach((btn) => btn.querySelector("[data-notification-read]").addEventListener("click", handleClick))

    document.querySelector("[data-notification-read-all]").
      addEventListener("click", () => notifications.forEach((notification) => handleFadeOut(notification)))
  }
}
