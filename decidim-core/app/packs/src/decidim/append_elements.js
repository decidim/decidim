import "@zeitiger/appendaround"

document.addEventListener("turbo:load", () => {
  let $appendableElements = $(".js-append");
  $appendableElements.appendAround();
})
