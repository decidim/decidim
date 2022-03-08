/**
 * Changes "Back to list" links to the one saved in sessionStorage API
 * To apply this to a link, at least one element must have the class "js-back-to-list".
 * For this to work it needs the filteredParams in SessionStorage, that's saved on FormFilterComponent.
 * @returns {void}
 */
 const backToListLink = function() {
  if ($(".js-back-to-list").length > 0) {

    if (!window.sessionStorage) {
      return;
    }

    const path = window.location.pathname;
    const filteredParams = JSON.parse(sessionStorage.getItem("filteredParams")) || {};
    Object.keys(filteredParams).forEach(function(url){
      if (path.includes(url)) {
        $(".js-back-to-list").attr("href", filteredParams[url]);
      }
    })
  }
}

$(document).ready(() => {
  backToListLink();
});
