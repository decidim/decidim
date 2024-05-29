let prevScrollpos = window.pageYOffset;
const header = document.getElementById("main-bar");
const headerHeight = header.offsetHeight;

window.addEventListener('scroll', function() {
  let currentScrollPos = window.pageYOffset;
  if (prevScrollpos > currentScrollPos) {
    header.style.top = "0";
  } else {
    header.style.top = `-${headerHeight}px`;
  }
  prevScrollpos = currentScrollPos;
});
