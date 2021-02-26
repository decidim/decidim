/* eslint-disable no-invalid-this */
((exports) => {
  const { Foundation } = exports;

  $(() => {
    // True if small devices
    if (!Foundation.MediaQuery.atLeast("medium")) {
      const $speaker = $(".js-conference")

      $speaker.hover(function () {
        const top = $(window).scrollTop() + ($(window).height() * 0.1)
        $(this).find(".js-bio").css("top", top)
      })
    }
  });
})(window)
