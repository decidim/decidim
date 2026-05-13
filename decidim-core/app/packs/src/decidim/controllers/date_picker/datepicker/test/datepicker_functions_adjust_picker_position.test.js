/* global jest */

import { adjustPickerPosition } from "src/decidim/controllers/date_picker/datepicker/datepicker_functions";

describe("adjustDatePickerPosition", () => {
  let input = null;
  let parent = null;
  let datePickerContainer = null;

  let originalInnerHeight = window.innerHeight;

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

    // store original viewport height
    originalInnerHeight = window.innerHeight;
  });

  afterEach(() => {
    document.body.removeChild(parent);

    Reflect.defineProperty(window, "innerHeight", {
      writable: true,
      configurable: true,
      value: originalInnerHeight
    });

    jest.restoreAllMocks();
  });

  it("sets parent position to relative when static", () => {
    parent.style.position = "static";

    adjustPickerPosition(input, datePickerContainer, ".datepicker__date-column");

    expect(parent.style.position).toBe("relative");
  });

  it("does not change parent position when already positioned", () => {
    parent.style.position = "absolute";

    adjustPickerPosition(input, datePickerContainer, ".datepicker__date-column");

    expect(parent.style.position).toBe("absolute");
  });

  it("opens below when sufficient space below", () => {
    jest.spyOn(input, "getBoundingClientRect").mockReturnValue({
      top: 100,
      bottom: 140
    });

    Reflect.defineProperty(window, "innerHeight", {
      writable: true,
      configurable: true,
      value: 800
    });

    adjustPickerPosition(input, datePickerContainer, ".datepicker__date-column");

    expect(datePickerContainer.style.top).toBe("40px");
    expect(datePickerContainer.style.bottom).toBe("");
  });

  it("opens above when insufficient space below", () => {
    jest.spyOn(input, "getBoundingClientRect").mockReturnValue({
      top: 400,
      bottom: 440
    });

    Reflect.defineProperty(window, "innerHeight", {
      writable: true,
      configurable: true,
      value: 500
    });

    adjustPickerPosition(input, datePickerContainer, ".datepicker__date-column");

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

    adjustPickerPosition(input, datePickerContainer, ".datepicker__date-column");

    expect(datePickerContainer.style.top).toBe("40px");
    expect(datePickerContainer.style.bottom).toBe("");
  });

  it("always sets right position to 0px", () => {
    jest.spyOn(input, "getBoundingClientRect").mockReturnValue({
      top: 100,
      bottom: 140
    });

    adjustPickerPosition(input, datePickerContainer, ".datepicker__date-column");

    expect(datePickerContainer.style.right).toBe("0px");
  });
});


describe("adjustTimePickerPosition", () => {
  let input = null;
  let parent = null;
  let timePicker = null;

  let originalInnerHeight = window.innerHeight;

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
