// This script implements a sticky header that hides when participants scroll down and shows when they scroll up.
// Sticky headers allow users to quickly access the navigation, search, and utility-navigation elements without scrolling up to the top of the page.
// They increase the discoverability of the elements in the header.
let prevScroll = window.scrollY;
const stickyHeader = document.querySelector("[data-sticky-header]");

if (stickyHeader) {
  document.addEventListener("scroll", () => {
    // if a subelement is not visible it has no offsetParent
    const header = document.getElementById("main-bar").offsetParent;
    if (header) {
      let currentScroll = window.scrollY;
      let goingDown = prevScroll > currentScroll;
      let change = Math.abs(prevScroll - currentScroll);
      if (change > 5) {
        if (goingDown || currentScroll < stickyHeader.offsetHeight) {
          stickyHeader.style.top = 0;
        } else {
          stickyHeader.style.top = `-${stickyHeader.offsetHeight}px`;
        }
        prevScroll = currentScroll;
      }
    }
  });
};
