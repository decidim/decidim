/* global jest */

import { adjustPickerPosition } from "src/decidim/datepicker/datepicker_functions";

describe("adjustPickerPosition (timepicker)", () => {
  let input = null;
  let parent = null;
  let timePicker = null;

  let originalInnerHeight;

  beforeEach(() => {
    parent = document.createElement("div");
    parent.className = "datepicker__time-column";
    document.body.appendChild(parent);

    input = document.createElement("input");
    Reflect.defineProperty(input, "offsetHeight", {
      configurable: true,
      value: 30
    });
    parent.appendChild(input);

    timePicker = document.createElement("div");
    timePicker.className = "timepicker__container";
    parent.appendChild(timePicker);

    Reflect.defineProperty(timePicker, "offsetHeight", {
      configurable: true,
      value: 200
    });

    // store original value before any test mutates it
    originalInnerHeight = window.innerHeight;
  });

  afterEach(() => {
    // restore DOM
    document.body.removeChild(parent);

    // restore window.innerHeight (fix for CodeRabbit warning)
    Reflect.defineProperty(window, "innerHeight", {
      writable: true,
      configurable: true,
      value: originalInnerHeight
    });

    jest.restoreAllMocks();
  });

  it("sets parent position to relative when static", () => {
    parent.style.position = "static";

    adjustPickerPosition(input, timePicker, ".datepicker__time-column");

    expect(parent.style.position).toBe("relative");
  });

  it("opens below when there is enough space", () => {
    jest.spyOn(input, "getBoundingClientRect").mockReturnValue({
      top: 100,
      bottom: 130
    });

    Reflect.defineProperty(window, "innerHeight", {
      writable: true,
      configurable: true,
      value: 700
    });

    adjustPickerPosition(input, timePicker, ".datepicker__time-column");

    expect(timePicker.style.top).toBe("30px");
    expect(timePicker.style.bottom).toBe("");
  });

  it("opens above when there is not enough space below", () => {
    jest.spyOn(input, "getBoundingClientRect").mockReturnValue({
      top: 400,
      bottom: 430
    });

    Reflect.defineProperty(window, "innerHeight", {
      writable: true,
      configurable: true,
      value: 500
    });

    adjustPickerPosition(input, timePicker, ".datepicker__time-column");

    expect(timePicker.style.top).toBe("");
    expect(timePicker.style.bottom).toBe("30px");
  });

  it("always aligns to the right", () => {
    jest.spyOn(input, "getBoundingClientRect").mockReturnValue({
      top: 100,
      bottom: 130
    });

    adjustPickerPosition(input, timePicker, ".datepicker__time-column");

    expect(timePicker.style.right).toBe("0px");
  });
});
