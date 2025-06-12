// changes the value "menu" of role attribute set by a11y on div dropdown-menu-account and
// dropdown-menu-account-mobile which are inappropriate for accessibility
document.addEventListener("DOMContentLoaded", function(event) {
  setTimeout(() => {
    document.querySelector("#dropdown-menu-account").setAttribute("role", "dialog")
    document.querySelector("#dropdown-menu-account-mobile").setAttribute("role", "dialog")
  }, 300)
});
