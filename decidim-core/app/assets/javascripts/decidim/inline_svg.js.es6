//= require svg-injector

window.inlineSVG = function () {
  let $externalSvg = $("img.external-svg");
  SVGInjector($externalSvg, {
    each: (svg) => $(svg).show()
  });
}
