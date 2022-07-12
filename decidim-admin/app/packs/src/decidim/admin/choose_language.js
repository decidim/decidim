/* eslint-disable no-invalid-this */
/* eslint-disable require-jsdoc */

export default function initLanguageChangeSelect(elements) {
  elements.forEach((select) => {
    select.addEventListener("click", () => {
        let targetTabPaneSelector = select.value;
        let tabsContent = select.parentElement.parentElement.nextElementSibling;

        tabsContent.querySelector(".is-active").classList.remove("is-active");
        tabsContent.querySelector(targetTabPaneSelector).classList.add("is-active");
      }
    )
  });
}
