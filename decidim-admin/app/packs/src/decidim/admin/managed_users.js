import SubformTogglerComponent from "./subform_toggler.component"

const subformToggler = new SubformTogglerComponent({
  controllerSelect: $("select#impersonate_user_authorization_handler_name"),
  subformWrapperClass: "authorization-handler",
  globalWrapperSelector: "form"
});

$(() => {
  subformToggler.run();
});
