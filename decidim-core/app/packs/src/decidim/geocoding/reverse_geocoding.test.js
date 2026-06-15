/* global global, jest */

import { initializeReverseGeocoding } from "src/decidim/geocoding/reverse_geocoding";

describe("reverseGeocoding", () => {
  let container = null;
  let button = null;
  let input = null;
  let label = null;
  let mockGeolocation = null;
  let mockPost = null;
  let originalGeolocation = null;

  beforeEach(() => {
    document.body.innerHTML = "";

    container = document.createElement("div");
    container.innerHTML = `
      <label>
        <input id="test_address" type="text" />
        <div class="geocoding__locate">
          <button
            class="geocoding__button"
            type="button"
            data-input="test_address"
            data-error-no-location="Could not detect location."
            data-error-unsupported="Device not supported."
            data-locating-text="Locating..."
            data-url="/locate">
            Use my location
          </button>
        </div>
      </label>
    `;
    document.body.appendChild(container);

    button = container.querySelector(".geocoding__button");
    input = container.querySelector("#test_address");
    label = container.querySelector("label");

    originalGeolocation = navigator.geolocation;
    mockGeolocation = {
      getCurrentPosition: jest.fn()
    };
    Reflect.defineProperty(global.navigator, "geolocation", {
      value: mockGeolocation,
      configurable: true
    });

    mockPost = jest.fn();
    global.jQuery = jest.fn(() => ({ trigger: jest.fn() }));
    global.jQuery.post = mockPost;
    // eslint-disable-next-line id-length
    global.$ = global.jQuery;

    initializeReverseGeocoding();
  });

  afterEach(() => {
    Reflect.defineProperty(global.navigator, "geolocation", {
      value: originalGeolocation,
      configurable: true
    });
    jest.restoreAllMocks();
  });

  describe("when clicking the button", () => {
    it("shows the spinner and disables the button", () => {
      mockGeolocation.getCurrentPosition.mockImplementation(() => {});

      button.click();

      expect(button.disabled).toBe(true);
      expect(button.classList.contains("geocoding__button--locating")).toBe(true);
      expect(button.querySelector(".geocoding__spinner")).not.toBeNull();
      expect(button.textContent).toContain("Locating...");
    });

    it("uses custom locating text from data attribute", () => {
      button.dataset.locatingText = "Finding you...";
      mockGeolocation.getCurrentPosition.mockImplementation(() => {});

      button.click();

      expect(button.textContent).toContain("Finding you...");
    });

    it("stores original content for restoration", () => {
      mockGeolocation.getCurrentPosition.mockImplementation(() => {});

      button.click();

      expect(button.dataset.originalContent).toContain("Use my location");
    });
  });

  describe("when geolocation succeeds", () => {
    it("restores the button after successful reverse geocoding", () => {
      const mockPosition = {
        coords: { latitude: 40.7128, longitude: -74.006 }
      };
      mockGeolocation.getCurrentPosition.mockImplementation((success) => {
        success(mockPosition);
      });

      const mockDeferred = { fail: jest.fn() };
      mockPost.mockImplementation((url, data, callback) => {
        callback({ address: "New York, NY, USA" });
        return mockDeferred;
      });

      button.click();

      expect(button.disabled).toBe(false);
      expect(button.classList.contains("geocoding__button--locating")).toBe(false);
      expect(button.querySelector(".geocoding__spinner")).toBeNull();
      expect(button.textContent).toContain("Use my location");
      expect(input.value).toBe("New York, NY, USA");
    });

    it("restores the button when reverse geocoding fails", () => {
      const mockPosition = {
        coords: { latitude: 40.7128, longitude: -74.006 }
      };
      mockGeolocation.getCurrentPosition.mockImplementation((success) => {
        success(mockPosition);
      });

      const mockDeferred = { fail: jest.fn((callback) => {
        callback({}, "error", "Not Found");
      }) };
      mockPost.mockReturnValue(mockDeferred);

      button.click();

      expect(button.disabled).toBe(false);
      expect(button.classList.contains("geocoding__button--locating")).toBe(false);
      expect(button.textContent).toContain("Use my location");
    });
  });

  describe("when geolocation fails", () => {
    it("restores the button when user denies permission", () => {
      const mockError = { message: "User denied geolocation" };
      mockGeolocation.getCurrentPosition.mockImplementation((success, error) => {
        error(mockError);
      });

      button.click();

      expect(button.disabled).toBe(false);
      expect(button.classList.contains("geocoding__button--locating")).toBe(false);
      expect(button.textContent).toContain("Use my location");
    });

    it("shows an error message", () => {
      const mockError = { message: "User denied geolocation" };
      mockGeolocation.getCurrentPosition.mockImplementation((success, error) => {
        error(mockError);
      });

      button.click();

      const errorElement = label.querySelector(".form-error");
      expect(errorElement).not.toBeNull();
      expect(errorElement.textContent).toContain("Could not detect location.");
    });
  });

  describe("when geolocation is not supported", () => {
    it("shows an unsupported error and does not show spinner", () => {
      Reflect.defineProperty(global.navigator, "geolocation", {
        value: null,
        configurable: true
      });

      button.click();

      expect(button.disabled).toBe(false);
      expect(button.classList.contains("geocoding__button--locating")).toBe(false);
      const errorElement = label.querySelector(".form-error");
      expect(errorElement).not.toBeNull();
      expect(errorElement.textContent).toContain("Device not supported.");
    });
  });

  describe("when button is already disabled", () => {
    it("does not trigger geolocation again", () => {
      button.disabled = true;
      mockGeolocation.getCurrentPosition.mockImplementation(() => {});

      button.click();

      expect(mockGeolocation.getCurrentPosition).not.toHaveBeenCalled();
    });
  });
});
