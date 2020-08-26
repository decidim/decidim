$(() => {
  const $responsiveTabBlock = $(".responsive-tab-block");

  $responsiveTabBlock.click((event) => {
    if (event.target.closest(".is-active") !== null) {
      event.preventDefault();
      if (window.innerWidth <= 639) {
        $responsiveTabBlock.toggleClass("expanded");
      }
    }
  });
});
