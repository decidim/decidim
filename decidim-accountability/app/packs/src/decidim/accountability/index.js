import 'diff'
// TODO-blat: does this import work? The intention here was more similar to a require than to an import
import './version_diff'

$(() => {
  // Show category list on click when we are on a small scren
  if ($(window).width() < 768) {
    $(".category--section").click((event) => {
      $(event.currentTarget).next(".category--elements").toggleClass("active");
    });
  }
})
