/**
 * This file handles the interactions of the notifications site via javascript
 * @param {HTMLElement} node target node
 * @returns {void}
 */
export default function(node = document) {
  const noNotificationsText = node.querySelector("#empty-notifications")
  const handleRemove = ({ currentTarget }) => currentTarget.remove()
  const handleFadeOut = (element) => {
    if (element) {
      element.addEventListener("transitionend", handleRemove)
      element.style.opacity = 0
    }
  }
  const emptyNotifications = () => {
    noNotificationsText.hidden = false

    node.querySelector("#dropdown-menu-account [data-unread-notifications]").remove()
    if (!node.querySelector(".main-bar__notification").dataset.unreadConversations) {
      node.querySelector(".main-bar__notification").remove()
    }
  }
  const handleClick = ({ currentTarget }) => {
    handleFadeOut(currentTarget.closest("[data-notification]"))
    if (!node.querySelector("[data-notification]:not([style])")) {
      emptyNotifications()
    }
  }
  const hideReadAllButton = () => {
    handleFadeOut(node.querySelector("[data-notification-read-all]"))
  }

  const notifications = node.querySelectorAll("[data-notification]")

  if (notifications.length) {
    notifications.forEach((btn) => btn.querySelector("[data-notification-read]").addEventListener("click", handleClick))

    node.querySelector("[data-notification-read-all]").
      addEventListener(
        "click", () => {
          notifications.forEach((notification) => handleFadeOut(notification))
          emptyNotifications()
          hideReadAllButton()
        }
      )
  }
}
