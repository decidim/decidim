// Initialize the previous scroll position
let prevScroll = window.scrollY;

// Get the sticky header element by its ID
const stickyHeader = document.getElementById("js-sticky-header");

// Check if the sticky header element exists
if (stickyHeader) {
  document.addEventListener("scroll", () => {
    // if a subelement is not visible it has no offsetParent
    const header = document.getElementById("main-bar").offsetParent;
    if (header) {
      let currentScroll = window.scrollY;
      // Determine the position of the sticky header based on scroll direction
      if (prevScroll > currentScroll || currentScroll < stickyHeader.offsetHeight) {
        stickyHeader.style.top = 0;
      } else {
        // If scrolling down, hide the header by setting its top position to negative its height
        stickyHeader.style.top = `-${stickyHeader.offsetHeight}px`;
      }
      // Update the previous scroll position to the current scroll position
      prevScroll = currentScroll;
    }
  });
};
