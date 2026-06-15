import { Application } from "@hotwired/stimulus"
import OfflineBannerController from "src/decidim/controllers/offline_banner/controller";

describe("OfflineBannerController", () => {
  let application = null;
  let banner = null;
  const originalOnLine = Reflect.getOwnPropertyDescriptor(navigator, "onLine");

  const setOnLine = (value) => {
    Reflect.defineProperty(navigator, "onLine", { value, configurable: true });
  };

  const render = (markup = "") => {
    document.body.innerHTML = `
      ${markup}
      <div class="js-offline-message hidden" data-controller="offline-banner"></div>
    `;
    banner = document.querySelector(".js-offline-message");

    return new Promise((resolve) => {
      setTimeout(resolve, 0);
    });
  };

  beforeEach(() => {
    application = Application.start();
    application.register("offline-banner", OfflineBannerController);
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
    if (originalOnLine) {
      Reflect.defineProperty(navigator, "onLine", originalOnLine);
    }
  });

  describe("connect", () => {
    it("shows the banner when offline and no fallback is present", async () => {
      setOnLine(false);

      await render();

      expect(banner.style.display).toBe("block");
    });

    it("does not show the banner when offline but the fallback is present", async () => {
      setOnLine(false);

      await render('<main id="offline-fallback-html"></main>');

      expect(banner.style.display).toBe("");
    });

    it("does not show the banner when online", async () => {
      setOnLine(true);

      await render();

      expect(banner.style.display).toBe("");
    });
  });
});
