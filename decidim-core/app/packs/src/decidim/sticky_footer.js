// This script add margin to the footer when the sticky CTA Buttons are shown on mobile devices,
// so the footer is always visible.
//
// The sticky buttons show some of the main Call to Actions (CTAs) so that they remain accessible on the
// screen as the participant scrolls through the detailed view of the Meetings, Proposals, Surveys, and Budgets
// components.
//

const footer = document.querySelector("footer");
const stickyButtons = document.querySelector("[data-sticky-buttons]");
import { screens } from "tailwindcss/defaultTheme"

/**
 * Checks if a key is in the current viewport
 *
 * @param {('sm'|'md'|'lg'|'xl'|'2xl')} key - The key to check the screen size.
 * @returns {boolean} - Returns true if the screen size corresponds with the key
 */
const isScreenSize = (key) => {
  return window.matchMedia(`(min-width: ${screens[key]})`).matches;
}
const adjustCtasButtons = () => {
  if (!stickyButtons) {
    return;
  }

  // On focus or ephemereal mode we do not have footer
  if (!footer) {
    return;
  }

  if (isScreenSize("md")) {
    footer.style.marginBottom = "0px";
    return;
  }

  const marginBottom = stickyButtons.offsetHeight;
  footer.style.marginBottom = `${marginBottom}px`;
};

if (stickyButtons) {
  document.addEventListener("scroll", () => {
    adjustCtasButtons();
  });

  document.addEventListener("on:toggle", () => {
    adjustCtasButtons();
  });

  window.addEventListener("resize", () => {
    adjustCtasButtons();
  });
}
