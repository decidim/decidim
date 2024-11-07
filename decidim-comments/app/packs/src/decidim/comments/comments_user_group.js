document.addEventListener("DOMContentLoaded", () => {
  const button = document.querySelector("[data-comments-dropdown]");
  const dropdownId = button.getAttribute("data-target");
  const dropdownMenu = document.getElementById(dropdownId);

  dropdownMenu.querySelectorAll("input[type='radio']").forEach((input) => {
    input.addEventListener("click", () => {
      const authorInfo = input.closest(".comment__as-author-container").querySelector(".comment__as-author-info");

      if (authorInfo) {
        const authorContent = authorInfo.innerHTML;

        button.querySelector("span").innerHTML = authorContent;
        const selectedLi = input.closest("li");
        selectedLi.style.display = "none";

        dropdownMenu.querySelectorAll("li").forEach((li) => {
          if (li !== selectedLi) {
            li.style.display = "";
          }
        });
      }
    });
  });
});
