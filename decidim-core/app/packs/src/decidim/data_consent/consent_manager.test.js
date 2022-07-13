/* global global, jest */

import Cookies from "js-cookie";
import ConsentManager from "./consent_manager";

// Mock js-cookie so that we can store the return values from the "set" method
// in order to inspect their flags.
jest.mock("js-cookie", () => {
  const originalModule = jest.requireActual("js-cookie");

  return {
    // ...originalModule,
    cookieStorage: {},
    get: originalModule.get,
    set: function (name, value, options) {
      this.cookieStorage[name] = originalModule.set(name, value, options);
    }
  };
});

Reflect.deleteProperty(global.window, "location");
global.window = Object.create(window);
global.window.location = {
  protocol: "https:",
  hostname: "decidim.dev"
};

describe("ConsentManager", () => {
  const dialogContent = `
    <div id="cc-dialog-wrapper" class="flex-center" role="region">
      <div class="cc-dialog padding-vertical-1">
        <div class="row expanded">
          <div class="columns medium-12 large-8">
            <div class="cc-content">
              <div class="h5">Information about the cookies used on the website</div>
              <div>
                We use cookies on our website to improve the performance and content of the site. The cookies enable us to provide a more individual user experience and social media channels.
              </div>
            </div>
          </div>
          <div class="columns medium-12 large-4">
            <div class="cc-button-wrapper flex-center">
              <button id="cc-dialog-accept" class="button">
                Accept all
              </button>
              <button id="cc-dialog-reject" class="button hollow">
                Accept only essential
              </button>
              <button id="cc-dialog-settings" class="button clear" data-open="cc-modal" aria-controls="cc-modal" aria-haspopup="dialog" tabindex="0">
                Settings
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  `;
  const modalContent = `
    <div class="reveal cc-modal" id="cc-modal" role="dialog" data-close-on-click="false" data-close-on-esc="false" aria-modal="true" aria-hidden="true">
      <div class="reveal__header">
        <h3 class="reveal__title">Cookie settings</h3>
        <p>
          We use cookies to ensure the basic functionalities of the website and to enhance your online experience. You can choose for each category to opt-in/out whenever you want.
        </p>
      </div>

      <div class="cc-categories">
        <div class="category-wrapper margin-vertical-1" data-id="essential">
          <div class="category-row flex-center">
            <button class="cc-title padding-left-3">
              <span class="h5 cc-category-title">
                <strong>Essential</strong>
              </span>
            </button>
            <div class="cc-switch">
              <input class="switch-input" checked="checked" id="cc-essential" type="checkbox" name="essential" disabled="">
              <label class="switch-paddle" for="cc-essential">
                <span class="show-for-sr">Toggle Essential</span>
              </label>
            </div>
          </div>
          <div class="cc-description hide">
            <div class="description-text">
              <p>These cookies are essential for the proper functioning of my website. Without these cookies, the website would not work properly.</p>
            </div>
            <div class="cookie-details-wrapper">
              <div class="row detail-titles">
                <div class="columns small-2">Type</div>
                <div class="columns small-2">Name</div>
                <div class="columns small-2">Service</div>
                <div class="columns small-6">Description</div>
              </div>
              <div class="row cookie-detail-row">
                <div class="columns small-2">Cookie</div>
                <div class="columns small-2">_session_id</div>
                <div class="columns small-2">This website</div>
                <div class="columns small-6">
                  Allows websites to remember user within a website when they move between web pages.
                </div>
              </div>
              <div class="row cookie-detail-row">
                <div class="columns small-2">Cookie</div>
                <div class="columns small-2">decidim-consent</div>
                <div class="columns small-2">This website</div>
                <div class="columns small-6">
                  Stores information about the cookies allowed by the user on this website.
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="category-wrapper margin-vertical-1" data-id="preferences">
          <div class="category-row flex-center">
            <button class="cc-title padding-left-3">
              <span class="h5 cc-category-title">
                <strong>Preferences</strong>
              </span>
            </button>
            <div class="cc-switch">
              <input class="switch-input" id="cc-preferences" type="checkbox" name="preferences">
              <label class="switch-paddle" for="cc-preferences">
                <span class="show-for-sr">Toggle Preferences</span>
              </label>
            </div>
          </div>
          <div class="cc-description hide">
            <div class="description-text">
              <p>These cookies allow the website to remember the choices you have made in the past</p>
            </div>
          </div>
        </div>
        <div class="category-wrapper margin-vertical-1" data-id="analytics">
          <div class="category-row flex-center">
            <button class="cc-title padding-left-3">
              <span class="h5 cc-category-title">
                <strong>Analytics and statistics</strong>
              </span>
            </button>
            <div class="cc-switch">
              <input class="switch-input" id="cc-analytics" type="checkbox" name="analytics">
              <label class="switch-paddle" for="cc-analytics">
                <span class="show-for-sr">Toggle Analytics and statistics</span>
              </label>
            </div>
          </div>
          <div class="cc-description hide">
            <div class="description-text">
              <p>Analytics cookies are cookies that track how users navigate and interact with a website. The information collected is used to help the website owner improve the website.</p>
            </div>
          </div>
        </div>
        <div class="category-wrapper margin-vertical-1" data-id="marketing">
          <div class="category-row flex-center">
            <button class="cc-title padding-left-3">
              <span class="h5 cc-category-title">
                <strong>Marketing</strong>
              </span>
            </button>
            <div class="cc-switch">
              <input class="switch-input" id="cc-marketing" type="checkbox" name="marketing">
              <label class="switch-paddle" for="cc-marketing">
                <span class="show-for-sr">Toggle Marketing</span>
              </label>
            </div>
          </div>
          <div class="cc-description hide">
            <div class="description-text">
              <p>These cookies collect information about how you use the website, which pages you visited and which links you clicked on.</p>
            </div>
          </div>
        </div>
      </div>
      <div class="cc-buttons-wrapper flex-center">
        <div class="cc-buttons-left">
          <button id="cc-modal-accept" class="button" data-close="">Accept all</button>
          <button id="cc-modal-reject" class="button hollow" data-close="">Accept only essential</button>
        </div>
        <div class="cc-buttons-right">
          <button id="cc-modal-save" class="button clear" data-close="">Save settings</button>
        </div>
      </div>
    </div>
  `;
  const cookieWarningContent = `
    <div class="cookie-warning flex-center padding-1 hide">
      <p>You need to enable all cookies in order to see this content.</p>
      <a href="#" class="button margin-vertical-2" data-open="cc-modal">
        Change cookie settings
      </a>
    </div>
  `;

  const getCookie = (name) => {
    for (const [key, value] of Object.entries(Cookies.cookieStorage)) {
      if (key === name) {
        const cookie = {};
        value.split(";").forEach((cookieString) => {
          const kv = cookieString.trim().split("=");
          const val = kv[1] || true;

          if (kv[0] === key) {
            cookie.value = val;
          } else {
            cookie[kv[0]] = val;
          }
        });

        return cookie;
      }
    }

    return null;
  };

  let manager = null;
  const originalLocation = window.location;

  beforeEach(() => {
    Cookies.cookieStorage = {};

    document.body.innerHTML = dialogContent + modalContent + cookieWarningContent;

    const modal = document.querySelector("#cc-modal");
    const categories = [...modal.querySelectorAll(".category-wrapper")].map((el) => el.dataset.id);
    manager = new ConsentManager({
      modal: modal,
      categories: categories,
      cookieName: "decidim-consent",
      warningElement: document.querySelector(".cookie-warning")
    });
  });

  afterEach(() => {
    window.location = originalLocation;
  });

  describe("updateState", () => {
    let cookie = null;

    describe("when the current URL is secure", () => {
      beforeEach(() => {
        manager.updateState({ foo: "bar" });
        cookie = getCookie("decidim-consent");
      });

      it("sets the cookie with the correct value", () => {
        expect(cookie.value).toEqual("{%22foo%22:%22bar%22}");
      });

      it("sets the cookie with the correct expiry", () => {
        const expiry = Date.parse(cookie.expires);
        const oneYearFromNow = Date.now() + 3600 * 24 * 1000 * 365;

        // Expect it to be within a second of the expected expiry time because
        // it would be pretty hard to try to guess the exact same millisecond.
        expect(oneYearFromNow - 1000).toBeLessThan(expiry);
        expect(oneYearFromNow + 1000).toBeGreaterThan(expiry);
      });

      it("sets the cookie with the correct flags", () => {
        expect(cookie.domain).toEqual("decidim.dev");
        expect(cookie.sameSite).toEqual("Lax");
        expect(cookie.secure).toBe(true);
      });
    });

    describe("when the current URL is insecure", () => {
      beforeEach(() => {
        Reflect.defineProperty(window.location, "protocol", { value: "http:" })

        manager.updateState({ foo: "bar" });
        cookie = getCookie("decidim-consent");
      });

      it("does not set the secure flag", () => {
        expect(cookie.secure).toBeUndefined();
      });
    });
  });
});
