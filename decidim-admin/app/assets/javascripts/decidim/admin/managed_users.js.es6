// = require ./subform_toggler.component

((exports) => {
  const { SubformTogglerComponent } = exports.DecidimAdmin;

  const subformToggler = new SubformTogglerComponent({
    controllerSelect: $("select#impersonate_user_authorization_handler_name"),
    subformWrapperClass: "authorization-handler"
  });

  subformToggler.run();
})(window);
