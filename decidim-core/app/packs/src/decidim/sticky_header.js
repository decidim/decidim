// This script implements the sticky header and the sticky buttons. The sticky header hides when participants scroll down and shows when they scroll up.
// Sticky headers allow users to quickly access the navigation, search, and utility-navigation elements without scrolling up to the top of the page. They increase the discoverability of the elements in the header.
// The sticky buttons in the other hand, those are some of the main Call to Actions (CTAs) that remain accessible on the screen as the user scrolls through the detailed view of the Meetings, Proposals, Surveys, and Budgets components.

let prevScroll = window.scrollY;
const stickyHeader = document.querySelector("[data-sticky-header]");
const footer = document.querySelector("footer");
const stickyButtons = document.querySelectorAll("[data-sticky-buttons]");

const isElementInViewport = (element) => {
  const rect = element.getBoundingClientRect();
  return rect.top >= 0 && rect.bottom <= (window.innerHeight || document.documentElement.clientHeight);
};

const adjustCtasButtons = () => {
  if (!stickyButtons || !stickyButtons.length) {
    return;
  }

  let visibleButtons = Array.from(stickyButtons).filter(isElementInViewport);

  if (visibleButtons.length > 0) {
    const marginBottom = Math.max(...visibleButtons.map((ctasButton) => ctasButton.offsetHeight));
    footer.style.marginBottom = `${marginBottom}px`;
  } else {
    footer.style.marginBottom = 0;
  }
};

if (stickyHeader) {
  document.addEventListener("scroll", () => {
    // if a subelement is not visible it has no offsetParent
    const header = document.getElementById("main-bar").offsetParent;
    if (header && window.getComputedStyle(stickyHeader).position === "fixed") {
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

      adjustCtasButtons();
    }
  });

  document.addEventListener("on:toggle", () => {
    adjustCtasButtons();
  });
};
