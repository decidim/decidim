// This script implements the sticky header on mobile devices.
//
// The sticky header hides when participants scroll down and shows when they scroll up.
// Sticky headers allow users to quickly access the navigation, search, and utility-navigation
// elements without scrolling up to the top of the page. They increase the discoverability of the elements in the header.
//

import { screens } from "tailwindcss/defaultTheme"

let prevScroll = window.scrollY;
const stickyHeader = document.querySelector("[data-sticky-header]");

// Fix the menu bar container margin top when there are multiple elements in the sticky header
// As there could be different heights and we cannot know beforehand, we need to adjust this in a dynamic way
// For instance we could have the omnipresent banner, the admin bar and the offline banner
const fixMenuBarContainerMargin = () => {
  if (!stickyHeader) {
    return;
  }

  const isMaxScreenSize = (key) => {
    return window.matchMedia(`(max-width: ${screens[key]})`).matches;
  }

  const menuBarContainer = document.querySelector("#menu-bar-container");
  const marginTop = isMaxScreenSize("md")
    ? stickyHeader.offsetHeight
    : 0;

  menuBarContainer.style.marginTop = `${marginTop}px`;
}

document.addEventListener("DOMContentLoaded", () => {
  fixMenuBarContainerMargin();
});

window.addEventListener("resize", () => {
  fixMenuBarContainerMargin();
});

if (stickyHeader) {
  document.addEventListener("scroll", () => {
    fixMenuBarContainerMargin();

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
    }
  });
};
