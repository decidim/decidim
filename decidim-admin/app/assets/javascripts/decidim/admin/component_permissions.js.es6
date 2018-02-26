// = require ./subform_toggler.component

((exports) => {
  const { SubformTogglerComponent } = exports.DecidimAdmin;

  const subformToggler = new SubformTogglerComponent({
    controllerSelect: $("select[name$=\\[authorization_handler_name\\]]"),
    subformWrapperClass: "authorization-handler",
    globalWrapperSelector: "fieldset"
  });

  subformToggler.run();
})(window);
