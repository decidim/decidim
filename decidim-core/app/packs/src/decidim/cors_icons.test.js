/* global jest */

import "src/decidim/cors_icons"

describe("cors_icons", () => {
  let mockRails = null;
  let savedSuccess = null;

  beforeEach(() => {
    savedSuccess = null;

    document.body.innerHTML = `
      <p id="existing-content">existing</p>
      <div id="svg-cors-container" style="display: none"></div>
    `;

    mockRails = {
      ajax: jest.fn((options) => {
        savedSuccess = options.success;
      })
    };
    window.Rails = mockRails;
    window.Decidim = {
      config: {
        get: jest.fn(() => "/icons-sprite.svg")
      }
    };
  });

  afterEach(() => {
    document.body.innerHTML = "";
    Reflect.deleteProperty(window, "Rails");
    Reflect.deleteProperty(window, "Decidim");
  });

  it("requests the icons sprite from the configured path on turbo:load", () => {
    document.dispatchEvent(new CustomEvent("turbo:load"));

    expect(window.Decidim.config.get).toHaveBeenCalledWith("icons_path");
    expect(mockRails.ajax).toHaveBeenCalledTimes(1);
    expect(mockRails.ajax.mock.calls[0][0]).toMatchObject({
      url: "/icons-sprite.svg",
      type: "get"
    });
  });

  it("does nothing when the cors container is absent", () => {
    document.getElementById("svg-cors-container").remove();

    document.dispatchEvent(new CustomEvent("turbo:load"));

    expect(mockRails.ajax).not.toHaveBeenCalled();
  });

  it("inserts the serialized sprite as the first child of the body", () => {
    document.dispatchEvent(new CustomEvent("turbo:load"));

    const svgDoc = new DOMParser().parseFromString(
      "<svg xmlns=\"http://www.w3.org/2000/svg\"><symbol id=\"foo\"></symbol></svg>",
      "image/svg+xml"
    );
    savedSuccess(svgDoc);

    const container = document.getElementById("svg-cors-container");
    expect(document.body.firstElementChild).toBe(container);
    expect(container.innerHTML).toContain("<symbol");
    expect(container.innerHTML).toContain("foo");
  });
});
