let prevScrollpos = window.scrollY;
const mainBar = document.getElementById("main-bar");

window.onscroll = function() {
  // if a subelement is not visible it has no offsetParent
  const header = document.getElementById("main-dropdown-summary-mobile").offsetParent;
  if (header) {
    let currentScrollPos = window.scrollY;

    if (prevScrollpos > currentScrollPos) {
      mainBar.style.top = 0;
    } else {
      mainBar.style.top = `-${header.offsetHeight}px`;
    }
    prevScrollpos = currentScrollPos;
  }
};
