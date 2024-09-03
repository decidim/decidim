import Cookies from "js-cookie";

const ONBOARDING_COOKIE_EXPIRY = 365;
const DATA_KEY = "onboarding";

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-onboarding-action]").forEach((element) => {
    // the dialog-open data attribute is stealing the click event
    element.addEventListener("mousedown", () => {
      const action = element.dataset.onboardingAction;
      const model = element.dataset.onboardingModel;
      const permissionsHolder = element.dataset.onboardingPermissionsHolder;
      const redirectPath = element.dataset.onboardingRedirectPath;

      Cookies.set(DATA_KEY, JSON.stringify({ action, model, permissionsHolder, redirectPath }), {
        expires: ONBOARDING_COOKIE_EXPIRY
      });
    });
  });
});
