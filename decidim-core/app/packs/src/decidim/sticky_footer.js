// This script add margin to the footer when the sticky CTA Buttons are shown on mobile devices,
// so the footer is always visible.
//
// The sticky buttons show some of the main Call to Actions (CTAs) so that they remain accessible on the
// screen as the participant scrolls through the detailed view of the Meetings, Proposals, Surveys, and Budgets
// components.
//

const footer = document.querySelector("footer");
const stickyButtons = document.querySelector("[data-sticky-buttons]");

const adjustCtasButtons = () => {
  if (!stickyButtons) {
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
}
