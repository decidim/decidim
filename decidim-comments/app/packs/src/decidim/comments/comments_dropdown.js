// The code: 1. Manages a responsive "Add Comment" modal: Opens fullscreen on mobile (<= sm) and closes it via a "close" button.
// 2. Handles dropdown menus: Dynamically updates button content based on user selection, hides selected items, and manages dropdown visibility.
// This creates a responsive, interactive comment interface with mobile-friendly design and dynamic user group selection.

import { screens } from "tailwindcss/defaultTheme";

const addCommentMobile = function (addCommentCard) {
  addCommentCard.classList.remove("hidden");
  addCommentCard.classList.add("fullscreen");
}

const closeAddComment = function (addCommentCard) {
  addCommentCard.classList.add("hidden");
  addCommentCard.classList.remove("fullscreen");
}

document.addEventListener("DOMContentLoaded", () => {
  // Add comment card for mobile
  const smBreakpoint = parseInt(screens.sm.replace("px", ""), 10);
  const addCommentCard = document.getElementById("add-comment-anchor");
  document.querySelectorAll(".add-comment-mobile").forEach((addButtonMobile) => {
    if (window.matchMedia(`(max-width: ${smBreakpoint}px)`).matches) {
      if (addButtonMobile) {
        addButtonMobile.addEventListener("click", () => addCommentMobile(addCommentCard));
      }
    }
  });

  // Close comment modal
  const closeButton = document.querySelector(
    "#add-comment-anchor .close-add-comment-fullscreen"
  );
  if (closeButton) {
    closeButton.addEventListener("click", () =>
      closeAddComment(addCommentCard)
    );
  }


  // Dropdown menu for user_group
  document.querySelectorAll("[data-comments-dropdown]").forEach((button) => {
    const dropdownId = button.getAttribute("data-target");
    const dropdownMenu = document.getElementById(dropdownId);

    const firstLi = dropdownMenu.querySelector("li");
    const firstAuthorInfo = firstLi?.querySelector(".comment__as-author-info");
    if (firstAuthorInfo) {
      button.querySelector("span").innerHTML = firstAuthorInfo.innerHTML;
      firstLi.style.display = "none";
    }

    dropdownMenu.querySelectorAll("input[type='radio']").forEach((input) => {
      input.addEventListener("click", () => {
        const authorInfo = input.closest(".comment__as-author-container").querySelector(".comment__as-author-info");

        if (authorInfo) {
          const authorContent = authorInfo.innerHTML;

          setTimeout(() => {
            button.querySelector("span").innerHTML = authorContent;

            const selectedLi = input.closest("li");
            selectedLi.style.display = "none";
            dropdownMenu.querySelectorAll("li").forEach((li) => {
              if (li !== selectedLi) {
                li.style.display = "";
              }
            });
          }, 2000);
        }
      });
    });
  });
});
