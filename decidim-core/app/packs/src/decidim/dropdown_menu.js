// changes the value "menu" of role attribute set by a11y on div dropdown-menu-account and
// dropdown-menu-account-mobile which are inappropriate for accessibility
document.addEventListener("turbo:load", () => {
  const dropdownDiv = document.querySelector("#dropdown-menu-account");
  const dropdownMobileDiv = document.querySelector("#dropdown-menu-account-mobile");
  if (dropdownDiv) {
    setTimeout(() => {
      dropdownDiv.setAttribute("role", "dialog")
      dropdownMobileDiv.setAttribute("role", "dialog")
    }, 300)
  }
  const triggerButtonMobile = document.querySelector("#dropdown-trigger-links-mobile");
  if (triggerButtonMobile) {
    triggerButtonMobile.addEventListener("click", () => {
      dropdownMobileDiv.setAttribute("aria-modal", "true")
    })
  }
});

const menuContainer = document.getElementById("dropdown-menu-main-desktop");
const menuButton = document.getElementById("main-dropdown-summary-desktop");
const content = document.getElementById("content");
const footer = document.querySelector("footer");
const menuBar = document.getElementById("menu-bar-container");

if (menuButton !== null) {
  menuButton.addEventListener("click", function () {
    if (menuContainer === null) {
      return;
    }

    const isHidden = menuContainer.getAttribute("aria-hidden") === "true";

    if (isHidden) {
      menuContainer.setAttribute("aria-hidden", "false");
      content.style.opacity = "0.3";
      footer.style.opacity = "0.3";
      menuBar.style.opacity = "0.3";
    } else {
      menuContainer.setAttribute("aria-hidden", "true");
      content.style.opacity = "1";
      footer.style.opacity = "1";
      menuBar.style.opacity = "1";
    }
  });
}

if (menuContainer !== null) {
  document.addEventListener("click", function (event) {
    const isOpen = menuContainer.getAttribute("aria-hidden") === "false";
    const clickedInsideMenu = menuContainer.contains(event.target) || menuButton.contains(event.target);

    if (isOpen && !clickedInsideMenu) {
      menuContainer.setAttribute("aria-hidden", "true");
      content.style.opacity = "1";
      footer.style.opacity = "1";
    }
  });
}
