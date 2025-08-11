import "diff"
import "src/decidim/accountability/version_diff"

document.addEventListener("turbo:load", () => {
  // Show category list on click when we are on a small screen
  if ($(window).width() < 768) {
    $(".category--section").click((event) => {
      $(event.currentTarget).next(".category--elements").toggleClass("active");
    });
  }
})
