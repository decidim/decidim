((exports) => {
  const showHideNav = (evt) => {
    const navMenu = document.querySelector(".layout-nav");

    evt.preventDefault();
    navMenu.classList.toggle("is-nav-open");
  }

  const toggleNav = () => {
    const navTrigger = document.querySelector(".menu-trigger");

    navTrigger.addEventListener("click", showHideNav);
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.toggleNav = toggleNav;
})(window);
