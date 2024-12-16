// Dropdown menu for user_group
export const initializeCommentsDropdown = function (elements) {
  let dropdownButtons = document;

  if (elements === document) {
    dropdownButtons = document.querySelectorAll("[data-comments-dropdown]");
  } else if (elements instanceof NodeList || Array.isArray(elements)) {
    dropdownButtons = elements;
  } else {
    dropdownButtons = [elements];
  }

  dropdownButtons.forEach((button) => {
    const dropdownId = button.getAttribute("data-target");
    const dropdownMenu = document.getElementById(dropdownId);

    if (dropdownMenu) {
      const firstLi = dropdownMenu.querySelector("li");
      const firstAuthorInfo = firstLi?.querySelector(
        ".comment__as-author-info"
      );

      if (firstAuthorInfo) {
        button.querySelector("span").innerHTML = firstAuthorInfo.innerHTML;
        firstLi.style.display = "none";
      }

      dropdownMenu.querySelectorAll("li").forEach((li) => {
        li.addEventListener("click", () => {
          const input = li.querySelector("input[type='radio']");

          if (input) {
            input.checked = true;
            input.dispatchEvent(new Event("click"));

            const authorInfo = li.querySelector(".comment__as-author-info");

            if (authorInfo) {
              const authorContent = authorInfo.innerHTML;

              setTimeout(() => {
                button.querySelector("span").innerHTML = authorContent;

                li.style.display = "none";
                dropdownMenu.querySelectorAll("li").forEach((otherLi) => {
                  if (otherLi !== li) {
                    otherLi.style.display = "";
                  }
                });
              }, 500);
            }
          }
        });
      });
    }
  });
};
