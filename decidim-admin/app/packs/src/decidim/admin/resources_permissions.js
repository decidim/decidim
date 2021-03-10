import SubformMultiTogglerComponent from './subform_multi_toggler.component'

const subformMultiToggler = new SubformMultiTogglerComponent({
  controllerSelect: $("input[name$=\\[authorization_handlers\\]\\[\\]]"),
  subformWrapperClass: "authorization-handler",
  globalWrapperSelector: "fieldset"
});

subformMultiToggler.run();
