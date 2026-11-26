// The code: 1. Manages a responsive "Add Comment" modal: Opens fullscreen on mobile (<= sm) and closes it via a "close" button.
// 2. Handles dropdown menus: Dynamically updates button content based on user selection, hides selected items, and manages dropdown visibility.
// This creates a responsive, interactive comment interface with mobile-friendly design and dynamic user group selection.

import { initializeCommentsDropdown } from "../../decidim/comments/comments_dropdown";

// Add comment card for mobile
const addCommentMobile = (addCommentCard) => {
  addCommentCard.classList.remove("hidden");
  addCommentCard.classList.add("fullscreen");
};

const closeAddComment = (addCommentCard) => {
  addCommentCard.classList.add("hidden");
  addCommentCard.classList.remove("fullscreen");
};

const addCommentCardFor = (element) => {
  const comments = element.closest("[data-decidim-comments]");
  return comments && comments.querySelector(".add-comment");
};

// Delegated so it also works for comments loaded after turbo:load
document.addEventListener("click", (event) => {
  if (!(event.target instanceof Element)) {
    return;
  }

  const addButton = event.target.closest(".add-comment-mobile");
  if (addButton) {
    const addCommentCard = addCommentCardFor(addButton);
    if (addCommentCard) {
      addCommentMobile(addCommentCard);
    }
    return;
  }

  const closeButton = event.target.closest(".close-add-comment-fullscreen");
  if (closeButton) {
    const addCommentCard = closeButton.closest(".add-comment");
    if (addCommentCard) {
      closeAddComment(addCommentCard);
    }
  }
});

document.addEventListener("turbo:load", () => {
  // Initialize dropdown menu
  initializeCommentsDropdown(document);
});
