// The code: 1. Manages a responsive "Add Comment" modal: Opens fullscreen on mobile (<= sm) and closes it via a "close" button.
// 2. Handles dropdown menus: Dynamically updates button content based on user selection, hides selected items, and manages dropdown visibility.
// This creates a responsive, interactive comment interface with mobile-friendly design and dynamic user group selection.

import { screens } from "tailwindcss/defaultTheme"
import { initializeCommentsDropdown } from "../../decidim/comments/comments_dropdown";

// Add comment card for mobile
const addCommentMobile = function (addCommentCard) {
  const smBreakpoint = parseInt(screens.sm.replace("px", ""), 10);
  if (window.matchMedia(`(max-width: ${smBreakpoint}px)`).matches) {
    addCommentCard.classList.remove("hidden");
    addCommentCard.classList.add("fullscreen");
  }
};

const closeAddComment = function (addCommentCard) {
  addCommentCard.classList.add("hidden");
  addCommentCard.classList.remove("fullscreen");
}

document.addEventListener("DOMContentLoaded", () => {
  // Add comment card for mobile
  const addCommentCard = document.getElementById("add-comment-anchor");
  if (addCommentCard) {
    document.querySelectorAll(".add-comment-mobile").forEach((addButtonMobile) => {
      addButtonMobile.addEventListener("click", () => {
        addCommentMobile(addCommentCard);
      });
    });
  }

  // Close comment modal
  const closeButton = document.querySelector(
    "#add-comment-anchor .close-add-comment-fullscreen"
  );
  if (closeButton) {
    closeButton.addEventListener("click", () =>
      closeAddComment(addCommentCard)
    );
  }


  // Initialize dropdown menu
  initializeCommentsDropdown(document);
});
