/**
 * Scroll smoothly to bottom automatically when the page is fully loaded.
 * To apply this to a page, at least one element must have the class "scroll-to-bottom".
 * @returns {void}
 */
const scrollToBottom = () => {
  if (document.querySelector(".scroll-to-bottom") !== null) {
    window.scrollTo({
      top: document.body.scrollHeight,
      behavior: "smooth"
    });
  }
};

document.onreadystatechange = () => {
  if (document.readyState === "complete") {
    scrollToBottom();
  }
};
