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
            }, 500);
          }
        });
      });
    }
  });
};

