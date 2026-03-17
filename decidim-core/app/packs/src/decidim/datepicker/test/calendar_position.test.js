/* global jest */

import { adjustCalendarPosition } from "src/decidim/datepicker/generate_datepicker"

describe("adjustCalendarPosition", () => {
  let datePickerContainer = null,
      input = null,
      parent = null;

  beforeEach(() => {
    // Setup DOM structure
    parent = document.createElement("div");
    parent.className = "datepicker__date-column";
    document.body.appendChild(parent);

    input = document.createElement("input");
    Reflect.defineProperty(input, "offsetHeight", {
      configurable: true,
      value: 40
    });
    parent.appendChild(input);

    datePickerContainer = document.createElement("div");
    datePickerContainer.className = "datepicker__container";
    parent.appendChild(datePickerContainer);

    // Mock offsetHeight for calendar
    Reflect.defineProperty(datePickerContainer, "offsetHeight", {
      configurable: true,
      value: 300
    });
  });

  afterEach(() => {
    document.body.removeChild(parent);
  });

  it("sets parent position to relative when static", () => {
    parent.style.position = "static";
    adjustCalendarPosition(input, datePickerContainer);
    expect(parent.style.position).toBe("relative");
  });

  it("does not change parent position when already positioned", () => {
    parent.style.position = "absolute";
    adjustCalendarPosition(input, datePickerContainer);
    expect(parent.style.position).toBe("absolute");
  });

  it("opens below when sufficient space below", () => {
    // Mock getBoundingClientRect with space below
    jest.spyOn(input, "getBoundingClientRect").mockReturnValue({
      top: 100,
      bottom: 140
    });

    // Mock window.innerHeight
    Reflect.defineProperty(window, "innerHeight", {
      writable: true,
      configurable: true,
      value: 800
    });

    adjustCalendarPosition(input, datePickerContainer);

    expect(datePickerContainer.style.top).toBe("40px");
    expect(datePickerContainer.style.bottom).toBe("");
  });

  it("opens above when insufficient space below", () => {
    // Mock getBoundingClientRect with limited space below
    jest.spyOn(input, "getBoundingClientRect").mockReturnValue({
      top: 400,
      bottom: 440
    });

    Reflect.defineProperty(window, "innerHeight", {
      writable: true,
      configurable: true,
      value: 500
    });

    adjustCalendarPosition(input, datePickerContainer);

    expect(datePickerContainer.style.top).toBe("");
    expect(datePickerContainer.style.bottom).toBe("40px");
  });

  it("prefers opening below when space is equal above and below", () => {
    jest.spyOn(input, "getBoundingClientRect").mockReturnValue({
      top: 250,
      bottom: 290
    });

    Reflect.defineProperty(window, "innerHeight", {
      writable: true,
      configurable: true,
      value: 540
    });

    adjustCalendarPosition(input, datePickerContainer);

    expect(datePickerContainer.style.top).toBe("40px");
    expect(datePickerContainer.style.bottom).toBe("");
  });

  it("always sets right position to 0px", () => {
    jest.spyOn(input, "getBoundingClientRect").mockReturnValue({
      top: 100,
      bottom: 140
    });

    adjustCalendarPosition(input, datePickerContainer);

    expect(datePickerContainer.style.right).toBe("0px");
  });
});
