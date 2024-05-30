let prevScroll = window.scrollY;
const mainBar = document.getElementById("main-bar");

window.onscroll = function() {
  // if a subelement is not visible it has no offsetParent
  const header = document.getElementById("main-dropdown-summary-mobile").offsetParent;
  if (header) {
    let currentScroll = window.scrollY;

    if (prevScroll > currentScroll) {
      mainBar.style.top = 0;
    } else {
      mainBar.style.top = `-${header.offsetHeight}px`;
    }
    prevScroll = currentScroll;
  }
};
