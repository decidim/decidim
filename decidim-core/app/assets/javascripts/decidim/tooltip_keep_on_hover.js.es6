/* eslint-disable no-invalid-this */

$(() => {

  // Foundation requires plugins to be initializated
  setTimeout(function() {

    const $tooltips = $(".tooltip")

    $tooltips.
      on("mouseover", function() {
        $(`[data-keep-on-hover='true'][data-toggle='${this.id}']`).foundation("show");
      }).
      on("mouseout", function() {
        $(`[data-keep-on-hover='true'][data-toggle='${this.id}']`).foundation("hide");
      })
  }, 0);
});
