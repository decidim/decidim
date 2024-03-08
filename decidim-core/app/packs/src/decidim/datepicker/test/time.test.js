import {
  setHour,
  setMinute,
  formatInputTime,
  changeHourDisplay,
  changeMinuteDisplay,
  hourDisplay,
  minuteDisplay,
  formatTime
} from "src/decidim/datepicker/datepicker_functions"

describe("setHour", () => {
  it("returns the hour in correct 24-hour format", () => {
    const result = setHour("15:30", 24);
    expect(result).toBe(15);
  });

  it("returns the hour in correct 12-hour format when hour is more than 12", () => {
    const result = setHour("18:45", 12);
    expect(result).toBe(6);
  });

  it("returns 12 for 12-hour format when hour is 0", () => {
    const result = setHour("00:30", 12);
    expect(result).toBe(12);
  });

  it("returns the hour in correct 12-hour format when hour is less than or equal to 12", () => {
    const result = setHour("09:15", 12);
    expect(result).toBe(9);
  });
});

describe("setMinute", () => {
  it("returns the correct value", () => {
    const result = setMinute("12:45");
    expect(result).toBe(45);
  });

  it("returns the correct minute value when 0", () => {
    const result = setMinute("08:00");
    expect(result).toBe(0);
  });

  it("returns the correct single-digit value", () => {
    const result = setMinute("09:05");
    expect(result).toBe(5);
  });
});

describe("formatInputTime", () => {
  const setupDOM = () => {
    document.body.innerHTML = `
      <input type="radio" id="period_am_exampleInput" name="period">
      <input type="radio" id="period_pm_exampleInput" name="period">
    `;
  };

  describe("24-hour format", () => {
    it("returns the value in correct format", () => {
      setupDOM();
      const time = "15:30";
      const format = 24;
      const input = { id: "exampleInput" };

      const result = formatInputTime(time, format, input);

      expect(result).toBe("15:30");
    });
  })

  describe("12-hour format", () => {
    it("returns the value in correct format and checks the PM radio-button", () => {
      setupDOM();
      const time = "12:45";
      const format = 12;
      const input = { id: "exampleInput" };

      const result = formatInputTime(time, format, input);

      expect(result).toBe("12:45");
      expect(document.getElementById("period_pm_exampleInput").checked).toBeTruthy();
      expect(document.getElementById("period_am_exampleInput").checked).toBeFalsy();
    });

    it("returns the value in correct format", () => {
      setupDOM();
      const time = "00:25";
      const format = 12;
      const input = { id: "exampleInput" };

      const result = formatInputTime(time, format, input);

      expect(result).toBe("12:25");
      // We are not expecting a radio button to be selected here since in a real environment the selected button is not
      // handled by this method for values < 12
    });
  })
});


describe("changeHourDisplay", () => {
  describe("24-hour format", () => {
    it("should increase the hour", () => {
      expect(changeHourDisplay("increase", 10, 24)).toEqual(11);
    });

    it("should change hour from 23 -> 0", () => {
      expect(changeHourDisplay("increase", 23, 24)).toEqual(0);
    });

    it("should decrease the hour", () => {
      expect(changeHourDisplay("decrease", 10, 24)).toEqual(9);
    });

    it("should change the hour from 0 -> 23", () => {
      expect(changeHourDisplay("decrease", 0, 24)).toEqual(23);
    });
  });

  describe("12-hour format", () => {
    it("should increase the hour", () => {
      expect(changeHourDisplay("increase", 10, 12)).toEqual(11);
    });

    it("should change hour from 12 -> 1", () => {
      expect(changeHourDisplay("increase", 12, 12)).toEqual(1);
    });

    it("should decrease the hour", () => {
      expect(changeHourDisplay("decrease", 10, 12)).toEqual(9);
    });

    it("should change the hour from 1 -> 12", () => {
      expect(changeHourDisplay("decrease", 1, 12)).toEqual(12);
    });
  });

  it("should return null when invalid parameter", () => {
    expect(changeHourDisplay("invalid", 10, 12)).toBeNull();
  });
});

describe("changeMinuteDisplay", () => {
  describe("increase", () => {
    it("should increase the minute", () => {
      expect(changeMinuteDisplay("increase", 10)).toEqual(11);
    });

    it("should change the minute from 59 -> 0", () => {
      expect(changeMinuteDisplay("increase", 59)).toEqual(0);
    });
  });

  describe("decrease", () => {
    it("should decrease the minute", () => {
      expect(changeMinuteDisplay("decrease", 10)).toEqual(9);
    });

    it("should change the minute from 0 -> 59", () => {
      expect(changeMinuteDisplay("decrease", 0)).toEqual(59);
    });
  });

  it("should handle invalid input by returning null", () => {
    expect(changeMinuteDisplay("invalid", 10)).toBeNull();
  });
});

describe("hourDisplay", () => {
  it("should add a prefix zero for single-digit hours", () => {
    expect(hourDisplay(5)).toEqual("05");
    expect(hourDisplay(9)).toEqual("09");
  });

  it("should not add a prefix zero for double-digit hours", () => {
    expect(hourDisplay(10)).toEqual(10);
    expect(hourDisplay(15)).toEqual(15);
  });
});

describe("minuteDisplay", () => {
  it("should add a prefix zero for single-digit minutes", () => {
    expect(minuteDisplay(5)).toEqual("05");
    expect(minuteDisplay(9)).toEqual("09");
  });

  it("should not add a prefix zero for double-digit minutes", () => {
    expect(minuteDisplay(10)).toEqual(10);
    expect(minuteDisplay(15)).toEqual(15);
  });
});


describe("formatTime", () => {
  const id = "exampleInput";

  it("should convert 12-hour time to 24-hour time for AM", () => {
    document.body.innerHTML = `
      <input type="radio" id="period_am_exampleInput" checked> AM
      <input type="radio" id="period_pm_exampleInput"> PM
    `;

    expect(formatTime("09:30", 12, id)).toEqual("09:30");
    expect(formatTime("12:45", 12, id)).toEqual("00:45");
  });

  it("should convert 12-hour time to 24-hour time for PM", () => {
    document.body.innerHTML = `
      <input type="radio" id="period_am_exampleInput"> AM
      <input type="radio" id="period_pm_exampleInput" checked> PM
    `;

    expect(formatTime("03:15", 12, id)).toEqual("15:15");
    expect(formatTime("11:30", 12, id)).toEqual("23:30");
  });

  it("should return the original time for 24-hour format", () => {
    document.body.innerHTML = `
      <input type="radio" id="period_am_exampleInput"> AM
      <input type="radio" id="period_pm_exampleInput"> PM
    `;

    expect(formatTime("15:45", 24, id)).toEqual("15:45");
    expect(formatTime("08:20", 24, id)).toEqual("08:20");
  });
});
