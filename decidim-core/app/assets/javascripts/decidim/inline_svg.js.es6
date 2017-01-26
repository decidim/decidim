// = require svg-injector

(function() {
  let inlineSVG = function () {
    let $externalSvg = $("img.external-svg");
    SVGInjector($externalSvg, {
      each: (svg) => $(svg).show()
    });
  }

  $(() => {
    inlineSVG();
  });
}(window));
