// = require foundation
// = require modernizr
// = require owl.carousel.min
// = require svg4everybody.min
// = require appendAround
// = require decidim/inline_svg

/* globals svg4everybody */

$(document).on('turbolinks:load', () => {
  $(document).foundation();

  let $appendableElements = $('.js-append');
  $appendableElements.appendAround();

  inlineSVG();
  svg4everybody();
});
