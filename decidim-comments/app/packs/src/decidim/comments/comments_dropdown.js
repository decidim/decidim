const addCommentMobile = function (addCommentCard) {
  addCommentCard.classList.remove("hidden");
  addCommentCard.classList.add("fullscreen");
}

const closeAddComment = function (addCommentCard) {
  addCommentCard.classList.add("hidden");
  addCommentCard.classList.add("fullscreen");
}

document.addEventListener("DOMContentLoaded", () => {
  // Add comment card for mobile
  const addCommentCard = document.getElementById("add-comment-anchor");
  const addButtonMobile = document.querySelectorAll(".add-comment-mobile");
  const closeButton = document.querySelector(
    "#add-comment-anchor .close-add-comment-fullscreen"
  );

  if (addCommentCard.clientWidth <= 600) {
    if(addButtonMobile) {
      addButtonMobile.addEventListener("click", () => addCommentMobile(addCommentCard));
    }
  }

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
