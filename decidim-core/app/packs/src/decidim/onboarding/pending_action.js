import Cookies from "js-cookie";

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-onboarding-action]").forEach((element) => {
    // the dialog-open data attribute is stealing the click event
    element.addEventListener("mousedown", () => {
      const action = element.dataset.onboardingAction;
      const model = element.dataset.onboardingModel;
      const permissionsHolder = element.dataset.onboardingPermissionsHolder;
      const redirectPath = element.dataset.onboardingRedirectPath;

      Cookies.set("onboarding", JSON.stringify({ action, model, permissionsHolder, redirectPath }), {
        expires: 365
      });

      console.log("stored onboarding cookie", { action, model, permissionsHolder, redirectPath });
    });
  });
});
