// = require foundation
// = require modernizr
// = require owl.carousel.min
// = require svg4everybody.min
// = require appendAround
// = require svg-injector

/* globals svg4everybody */

$(document).on('turbolinks:load', () => {
  $(document).foundation();
  $('.js-append').appendAround();

  let externalSvg = $("img.external-svg");
  SVGInjector(externalSvg, {
    each: (svg) => $(svg).show()
  });

  svg4everybody();
});
