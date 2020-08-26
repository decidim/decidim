/**
 * Scroll smoothly to the last message automatically when the page is fully loaded.
 * To apply this to a page, at least one element must have the class "scroll-to-last-message".
 * @returns {void}
 */
const scrollToLastMessage = () => {
  if ($(".scroll-to-last-message").length > 0) {
    window.scrollTo({
      top: $(".conversation-chat:last-child").offset().top,
      behavior: "smooth"
    });
  }
};

$(document).ready(() => {
  scrollToLastMessage();
});
