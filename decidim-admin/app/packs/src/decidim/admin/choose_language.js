/* eslint-disable no-invalid-this */
/* eslint-disable require-jsdoc */

export default function initLanguageChangeSelect(elements) {
  elements.forEach((select) => {
    select.onchange = function () {
      let targetTabPaneSelector = this.value;
      let $tabsContent = this.parentElement.parentElement.nextElementSibling;

      $tabsContent.querySelector(".is-active").classList.remove("is-active");
      $tabsContent.querySelector(targetTabPaneSelector).classList.add("is-active");
    }
  });
}
