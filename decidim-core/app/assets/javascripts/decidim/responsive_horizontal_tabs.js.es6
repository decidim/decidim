$(() => {
  const $responsiveTabBlock = $(".responsive-tab-block");

  $responsiveTabBlock.click((e) => {
    if (e.target.closest(".is-active") !== null){
      e.preventDefault();
      if(window.innerWidth <= 639){
        $responsiveTabBlock.toggleClass("expanded");
      }
    }
  });
});