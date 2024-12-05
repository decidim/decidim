import Cookies from "js-cookie";

const ONBOARDING_COOKIE_EXPIRY = 365;

// The same key is set in the Decidim::OnboardingManager class to retrieve the data from the cookie and store it in the extended data attribute
const DATA_KEY = "onboarding";

/**
 * @param {DOMElement} element Element which provides the information for cookie about action to perform.
 * @return {Void} Nothing
 */
export default function setOnboardingAction(element) {
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
}
