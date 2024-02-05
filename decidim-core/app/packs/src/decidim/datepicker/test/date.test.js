/* global jest */

import {
  dateToPicker,
  displayDate,
  formatDate,
  formatInputDate,
  calculateDatepickerPos
} from "src/decidim/datepicker/datepicker_functions"

describe("dateToPicker", () => {
  it('should format date from "d-m-y" to "m-d-y" -format for datepicker', () => {
    const inputDate = "01/02/2023";
    const formats = { separator: "/", order: "d-m-y" };

    const result = dateToPicker(inputDate, formats);

    expect(result).toEqual("02/01/2023");
  });

  it('should format date from "y-m-d" to "m-d-y" -format for datepicker', () => {
    const inputDate = "2023.02.01";
    const formats = { separator: ".", order: "y-m-d" };

    const result = dateToPicker(inputDate, formats);

    expect(result).toEqual("02/01/2023");
  });
});

describe("displayDate", () => {
  it('should format date in "d-m-y" order correctly', () => {
    const inputDate = new Date("2023-02-01");
    const formats = { separator: "/", order: "d-m-y" };

    const result = displayDate(inputDate, formats);

    expect(result).toEqual("01/02/2023");
  });

  it('should format date in "y-m-d" order correctly', () => {
    const inputDate = new Date("2023-02-01");
    const formats = { separator: ".", order: "y-m-d" };

    const result = displayDate(inputDate, formats);

    expect(result).toEqual("2023.02.01");
  });
});

describe("formatDate", () => {
  it('should format date in "d-m-y" -format correctly to "datetime-local" or "date" formfield', () => {
    const inputDate = "01/02/2023";
    const formats = { separator: "/", order: "d-m-y" };

    const result = formatDate(inputDate, formats);

    expect(result).toEqual("2023-02-01");
  });

  it('should format date in "y-m-d" -format correctly to "datetime-local" or "date" formfield', () => {
    const inputDate = "2023.02.01";
    const formats = { separator: ".", order: "y-m-d" };

    const result = formatDate(inputDate, formats);

    expect(result).toEqual("2023-02-01");
  });
});

describe("formatInputDate", () => {
  it('should format date in "d-m-y" order correctly', () => {
    const inputDate = "2023-02-01";
    const formats = { separator: "/", order: "d-m-y" };

    const result = formatInputDate(inputDate, formats);

    expect(result).toEqual("01/02/2023");
  });

  it('should format date in "y-m-d" order correctly', () => {
    const inputDate = "2023-02-01";
    const formats = { separator: ".", order: "y-m-d" };

    const result = formatInputDate(inputDate, formats);

    expect(result).toEqual("2023.02.01");
  });
});

describe("calculateDatepickerPos", () => {
  it("should calculate datepicker position correctly in Admin panel", () => {
    Reflect.defineProperty(document.body, "clientHeight", {
      value: 800,
      writable: true
    });

    Reflect.defineProperty(window, "scrollY", {
      value: 200,
      writable: true
    });

    const datePicker = {
      getBoundingClientRect: jest.fn(() => ({
        top: 300
      })),
      clientHeight: 100
    };

    jest.spyOn(document, "querySelector").mockReturnValue({
      clientHeight: 50
    });

    const result = calculateDatepickerPos(datePicker);

    expect(result).toEqual(150);
  });
});
