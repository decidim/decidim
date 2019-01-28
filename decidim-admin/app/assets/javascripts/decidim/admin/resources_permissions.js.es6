// = require ./subform_multi_toggler.component

((exports) => {
  const { SubformMultiTogglerComponent } = exports.DecidimAdmin;

  const subformMultiToggler = new SubformMultiTogglerComponent({
    controllerSelect: $("input[name$=\\[authorization_handlers\\]\\[\\]]"),
    subformWrapperClass: "authorization-handler",
    globalWrapperSelector: "fieldset"
  });

  subformMultiToggler.run();
})(window);
