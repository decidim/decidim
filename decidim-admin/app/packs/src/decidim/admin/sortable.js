import sortable from "html5sortable/dist/html5sortable.es";

/*
  Initializes any element with the class js-sortable as a sortable list
  User html5Sortable, with options available as data-draggable-options (see https://github.com/lukasoppermann/html5sortable)

  Event are dispatched on the element with the class js-sortable, so you can simply do:

  document.querySelector('.js-sortable').addEventListener('sortupdate', (event) => {
    console.log('The new order is:', event.target.children);
  });
*/
window.addEventListener("DOMContentLoaded", () => {
  const draggables = document.querySelectorAll(".js-sortable");

  if (draggables) {
    draggables.forEach((draggable) => {
      let options = {
        "forcePlaceholderSize": true
      };
      ["items", "acceptFrom", "handle", "placeholderClass", "placeholder", "hoverClass"].forEach((option) => {
        let dataOption = `draggable${option.charAt(0).toUpperCase() + option.slice(1)}`;
        if (draggable.dataset[dataOption]) {
          options[option] = draggable.dataset[dataOption];
        }
      });
      // console.log("initialize sortable with options", options);
      sortable(draggable, options);
    });
  }
});
