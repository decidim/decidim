import SubformMultiTogglerComponent from "src/decidim/admin/subform_multi_toggler.component"

document.addEventListener("turbo:load", () => {
  const subformMultiToggler = new SubformMultiTogglerComponent({
    controllerSelect: $("input[name$=\\[authorization_handlers\\]\\[\\]]"),
    subformWrapperClass: "authorization-handler",
    globalWrapperSelector: "fieldset"
  });

  subformMultiToggler.run();
})
