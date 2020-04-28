$(() => {
  const $responsiveTabBlock = $(".responsive-tab-block");

  $responsiveTabBlock.click((event) => {
    if (event.target.closest(".is-active") !== null) {
      e.preventDefault();
      if (window.innerWidth <= 639) {
        $responsiveTabBlock.toggleClass("expanded");
      }
    }
  });
});
