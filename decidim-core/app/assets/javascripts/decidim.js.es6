// = require foundation
// = require modernizr
// = require owl.carousel.min
// = require svg4everybody.min
// = require decidim/append_elements
// = require decidim/inline_svg

/* globals svg4everybody */

$(document).on('turbolinks:load', () => {
  $(document).foundation();
  svg4everybody();
});
