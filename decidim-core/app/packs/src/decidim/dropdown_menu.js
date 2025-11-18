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

const setMenuOpacity = (opacity) => {
  const content = document.getElementById("content");
  const footer = document.querySelector("footer");
  const menuBar = document.getElementById("menu-bar-container");

  if (content) {
    content.style.opacity = opacity;
  }
  if (footer) {
    footer.style.opacity = opacity;
  }
  if (menuBar) {
    menuBar.style.opacity = opacity;
  }
}

const menuContainer = document.getElementById("dropdown-menu-main-desktop");
const menuButton = document.getElementById("main-dropdown-summary-desktop");

if (menuButton && menuContainer) {
  menuButton.addEventListener("click", function () {
    const isHidden = menuContainer.getAttribute("aria-hidden") === "true";
    if (!isHidden) {
      return;
    }
    setTimeout(() => {
      setMenuOpacity("0.3");
      document.body.style.overflow = "hidden";
      menuContainer.setAttribute("aria-hidden", "false");
      window.scrollTo({ top: 0, behavior: "smooth" });
    }, 50);
  });
}

if (menuContainer) {
  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
      const isOpen = menuContainer.getAttribute("aria-hidden") === "true";

      if (isOpen) {
        menuContainer.setAttribute("aria-hidden", "true");
        setMenuOpacity("1");
        document.body.style.overflow = "scroll";
      }
    }
  })

  document.addEventListener("click", function (event) {
    const isOpen = menuContainer.getAttribute("aria-hidden") === "false";
    const closeMenuButton = document.getElementById("main-dropdown-summary-desktop-close");
    const clickedInsideMenu = menuContainer.contains(event.target);
    const clickCloseButton = closeMenuButton && closeMenuButton.contains(event.target);

    if (isOpen && (!clickedInsideMenu || clickCloseButton)) {
      menuContainer.setAttribute("aria-hidden", "true");
      setMenuOpacity("1");
      document.body.style.overflow = "scroll";
    }
  });
}
