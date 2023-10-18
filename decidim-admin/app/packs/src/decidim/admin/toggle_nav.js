/* eslint-disable require-jsdoc */
const showHideNav = (evt) => {
  const navMenu = document.querySelector(".layout-wrapper");

  evt.preventDefault();
  navMenu.classList.toggle("is-nav-open");
}

export default function toggleNav() {
  const navTrigger = document.querySelector(".menu-trigger");
  if (navTrigger) {
    navTrigger.addEventListener("click", showHideNav);
  }
}
