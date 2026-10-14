import "src/decidim/offline_banner"

describe("offline_banner", () => {
  let banner = null;
  const originalOnLine = Reflect.getOwnPropertyDescriptor(navigator, "onLine");

  const setOnLine = (value) => {
    Reflect.defineProperty(navigator, "onLine", { value, configurable: true });
  };

  const render = (markup = "") => {
    document.body.innerHTML = `
      ${markup}
      <div class="js-offline-message hidden"></div>
    `;
    banner = document.querySelector(".js-offline-message");
  };

  afterEach(() => {
    document.body.innerHTML = "";
    if (originalOnLine) {
      Reflect.defineProperty(navigator, "onLine", originalOnLine);
    }
  });

  it("shows the banner when offline and no fallback is present", () => {
    setOnLine(false);
    render();

    document.dispatchEvent(new CustomEvent("turbo:load"));

    expect(banner.style.display).toBe("block");
  });

  it("does not show the banner when offline but the fallback is present", () => {
    setOnLine(false);
    render('<main id="offline-fallback-html"></main>');

    document.dispatchEvent(new CustomEvent("turbo:load"));

    expect(banner.style.display).toBe("");
  });

  it("does not show the banner when online", () => {
    setOnLine(true);
    render();

    document.dispatchEvent(new CustomEvent("turbo:load"));

    expect(banner.style.display).toBe("");
  });
});
