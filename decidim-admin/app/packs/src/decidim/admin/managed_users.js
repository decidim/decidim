/* eslint-disable require-jsdoc */

import SubformTogglerComponent from "src/decidim/admin/subform_toggler.component"

export default function managedUsersForm() {
  const subformToggler = new SubformTogglerComponent({
    controllerSelect: $("select#impersonate_user_authorization_handler_name"),
    subformWrapperClass: "authorization-handler",
    globalWrapperSelector: "form"
  });

  subformToggler.run();
}
