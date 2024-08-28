import Cookies from "js-cookie";

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-onboarding-action]").forEach((element) => {
    // the dialog-open data attribute is stealing the click event
    element.addEventListener("mousedown", () => {
      const action = element.dataset.onboardingAction;
      const model = element.dataset.onboardingModel;
      const permissions_holder = element.dataset.onboardingPermissionsHolder;
      const redirect_path = element.dataset.onboardingRedirectPath;

      Cookies.set("onboarding", JSON.stringify({ action, model, permissions_holder, redirect_path }), {
        expires: 365
      });

      console.log("stored onboarding cookie", { action, model, permissions_holder, redirect_path });
    });
  });
});
