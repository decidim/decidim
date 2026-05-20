import { Application } from "@hotwired/stimulus"

import AccordionController from "src/decidim/controllers/accordion/controller";
import AccountFormController from "src/decidim/controllers/account_form/controller"
import AssignRoleController from "src/decidim/controllers/assign_role/controller";
import CharacterCounterController from "src/decidim/controllers/character_counter/controller";
import ClipboardCopyController from "src/decidim/controllers/clipboard_copy/controller";
import DeleteAccountFormController from "src/decidim/controllers/delete_account_form/controller";
import DropdownController from "src/decidim/controllers/dropdown/controller";
import FormFilterController from "src/decidim/controllers/form_filter/controller";
import FormValidatorController from "src/decidim/controllers/form_validator/controller";
import ImpersonationWarningController from "src/decidim/controllers/impersonation_warning/controller"
import InputTagsController from "src/decidim/controllers/input_tags/controller"
import LanguageChangeController from "src/decidim/controllers/language_change/controller";
import MainMenuController from "src/decidim/controllers/main_menu/controller"
import MentionController from "src/decidim/controllers/mention/controller";
import MultipleMentionsController from "src/decidim/controllers/multiple_mentions/controller"
import NotificationActionController from "src/decidim/controllers/notification_action/controller"
import PasswordTogglerController from "src/decidim/controllers/password_toggler/controller";
import ReportFormController from "src/decidim/controllers/report_form/controller";
import ScrollToLastController from "src/decidim/controllers/scroll_to_last/controller";
import StickyButtonsController from "src/decidim/controllers/sticky_buttons/controller";
import ToggleController from "src/decidim/controllers/toggle/controller";
import TooltipController from "src/decidim/controllers/tooltip/controller"
import UserRegistrationFormController from "src/decidim/controllers/user_registration_form/controller";
import TabsController from "src/decidim/controllers/tabs/controller";

import { definitionsFromContext } from "src/decidim/refactor/support/stimulus"

const application = Application.start()

application.register("accordion", AccordionController);
application.register("account-form", AccountFormController);
application.register("assign-role", AssignRoleController);
application.register("character-counter", CharacterCounterController);
application.register("clipboard-copy", ClipboardCopyController);
application.register("delete-account-form", DeleteAccountFormController);
application.register("dropdown", DropdownController);
application.register("form-filter", FormFilterController);
application.register("form-validator", FormValidatorController);
application.register("impersonation-warning", ImpersonationWarningController)
application.register("input-tags", InputTagsController)
application.register("language-change", LanguageChangeController);
application.register("main-menu", MainMenuController)
application.register("mention", MentionController);
application.register("multiple-mentions", MultipleMentionsController);
application.register("notification-action", NotificationActionController)
application.register("password-toggler", PasswordTogglerController);
application.register("report-form", ReportFormController);
application.register("scroll-to-last", ScrollToLastController);
application.register("sticky-buttons", StickyButtonsController);
application.register("toggle", ToggleController);
application.register("tooltip", TooltipController)
application.register("user-registration-form", UserRegistrationFormController);
application.register("tabs", TabsController);

application.debug = true

window.definitionsFromContext = definitionsFromContext
window.Stimulus = application

document.addEventListener("turbo:load", () => {
  document.dispatchEvent(new CustomEvent("stimulus:load", { detail: { document } }));
});
