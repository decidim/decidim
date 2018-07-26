/* global Foundation */
/* eslint-disable no-invalid-this */
$(() => {
  if (!Foundation.MediaQuery.atLeast("medium")) {
    // True if small
    const $speaker = $(".js-conference")

    $speaker.hover(function () {
      const top = $(window).scrollTop()
      $(this).find(".js-bio").css("top", top)
    })

// REVIEW: Mirar el data toggler
    $speaker.find("[data-close]").click(function () {
      const $vm = $(this)

      // Wait for the animation ends
      setTimeout(function () {
        $vm.closest(".js-bio").removeAttr("style")
      }, 500);
    })
  }
});
