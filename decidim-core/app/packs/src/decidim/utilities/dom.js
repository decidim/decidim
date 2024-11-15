import confirmAction from "src/decidim/confirm"
import { getMessages } from "src/decidim/i18n"

const { Rails } = window;

const createUnloadPreventer = () => {
  const preventUnloadConditions = [];

  const confirmMessage = getMessages("confirmUnload") || "Are you sure you want to leave this page?";

  const canUnload = (event) => !preventUnloadConditions.some((condition) => condition(event));

  // TLDR:
  // The beforeunload event does not work during tests due to the deprecation of
  // the unload event and ChromeDriver automatically accepting these dialogs.
  // ---
  //
  // Even when there are custom listeners on links and forms, the beforeunload
  // event is to ensure that the user does not accidentally reload the page or
  // close the browser or the tab. Note that this does not work during the tests
  // with ChromeDriver due to the deprecation of the unload event and
  // ChromeDriver automatically accepting these dialogs. For the time being,
  // this should work when a real user interacts with the browser along with the
  // "Permissions-Policy" header set by the backend. For more information about
  // the header, see Decidim::Headers::BrowserFeaturePermissions).
  const unloadListener = (event) => {
    if (canUnload(event)) {
      return;
    }

    // According to:
    // https://developer.mozilla.org/en-US/docs/Web/API/Window/beforeunload_event
    //
    // > [...] best practice is to trigger the dialog by invoking
    // > preventDefault() on the event object, while also setting returnValue to
    // > support legacy cases.
    event.preventDefault();
    event.returnValue = true;
  };

  // The beforeunload event listener has to be registered AFTER a user
  // interaction which is why it is wrapped around the next click event that
  // happens after the first unload listener was registered. Otherwise it might
  // not work due to the deprecation of the unload APIs in Chromium based
  // browsers and possibly in the web standards in the future.
  //
  // According to:
  // https://developer.chrome.com/docs/web-platform/page-lifecycle-api#the_beforeunload_event
  //
  // > Never add a beforeunload listener unconditionally or use it as an
  // > end-of-session signal. Only add it when a user has unsaved work, and
  // > remove it as soon as that work has been saved.
  const registerBeforeUnload = () => {
    window.removeEventListener("click", registerBeforeUnload);
    window.addEventListener("beforeunload", unloadListener);
  };

  const disableBeforeUnload = () => {
    window.removeEventListener("click", registerBeforeUnload);
    window.removeEventListener("beforeunload", unloadListener);
  };

  const linkClickListener = (ev) => {
    const link = ev.target?.closest("a");
    if (!link) {
      return;
    }

    if (canUnload(ev)) {
      disableBeforeUnload();
      document.removeEventListener("click", linkClickListener);
      return;
    }

    window.exitUrl = link.href;

    ev.preventDefault();
    ev.stopPropagation();

    confirmAction(confirmMessage, link).then((answer) => {
      if (!answer) {
        return;
      }

      disableBeforeUnload();
      document.removeEventListener("click", linkClickListener);
      link.click();
    });
  };

  const formSubmitListener = (ev) => {
    const source = ev.target?.closest("form");
    if (!source) {
      return;
    }

    if (canUnload(ev)) {
      disableBeforeUnload();
      document.removeEventListener("submit", formSubmitListener);
      return;
    }

    const button = source.closest(Rails.formSubmitSelector);
    if (!button) {
      return;
    }

    ev.preventDefault();
    ev.stopImmediatePropagation();
    ev.stopPropagation();

    confirmAction(confirmMessage, button).then((answer) => {
      if (!answer) {
        return;
      }

      disableBeforeUnload();
      document.removeEventListener("submit", formSubmitListener);
      source.submit();
    });
  };

  const registerPreventUnloadListeners = () => {
    window.addEventListener("click", registerBeforeUnload);
    document.addEventListener("click", linkClickListener);
    document.addEventListener("submit", formSubmitListener);
  };

  return {
    addPreventCondition: (condition) => {
      if (typeof condition !== "function") {
        return;
      }

      if (preventUnloadConditions.length < 1) {
        // The unload listeners are global, so only the first call to this
        // function should result to registering these listeners.
        registerPreventUnloadListeners();
      }

      preventUnloadConditions.push(condition);
    }
  };
};

const unloadPreventer = createUnloadPreventer();

export const preventUnload = (condition) => unloadPreventer.addPreventCondition(condition);
