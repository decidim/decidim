// This script aims to dynamically adjust the height of the .budget-summary__content element based on the heights of two of its child elements,
// but only when .budget-summary__content__header is within the viewport.
const isElementInViewport = (el) => {
  const rect = el.getBoundingClientRect();
  return (
    rect.top >= 0 &&
    rect.left >= 0 &&
    rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
    rect.right <= (window.innerWidth || document.documentElement.clientWidth)
  );
};
  
document.addEventListener("DOMContentLoaded", () => {
  const budgetSummaryContentHeader = document.querySelector(".budget-summary__content__header");
  
  if (budgetSummaryContentHeader) {
    if (isElementInViewport(budgetSummaryContentHeader)) {
      const budgetSummaryContent = document.querySelector(".budget-summary__content");
      const budgetSummaryProgressbox = document.querySelector(".budget-summary__progressbox");
      const budgetSummaryContentHeaderDescription = document.querySelector(".budget-summary__content__header--description");
  
      if (budgetSummaryContent) {
        budgetSummaryContent.style.height = `${budgetSummaryProgressbox.offsetHeight + budgetSummaryContentHeaderDescription.offsetHeight}px`;
      }
    }
  }
});
