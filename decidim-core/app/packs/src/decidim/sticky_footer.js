// This script add margin to the footer when the sticky CTA Buttons are shown on mobile devices,
// so the footer is always visible.
// 
// The sticky buttons show some of the main Call to Actions (CTAs) so that they remain accessible on the
// screen as the participant scrolls through the detailed view of the Meetings, Proposals, Surveys, and Budgets
// components.
// 

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

if (stickyButtons) {
  document.addEventListener("scroll", () => {
    adjustCtasButtons();
  });

  document.addEventListener("on:toggle", () => {
    adjustCtasButtons();
  });
}
