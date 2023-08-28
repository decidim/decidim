/* eslint-disable require-jsdoc */

export const changeHourDisplay = (change, hour) => {
  let value = null;

  if (change === "increase") {
    if (hour === 23) {
      value = 0;
    } else {
      value = hour + 1;
    };
  } else if (change === "decrease") {
    if (hour === 0) {
      value = 23;
    } else {
      value = hour - 1;
    };
  };

  return value;
};

export const changeMinuteDisplay = (change, minute) => {
  let value = null;
  if (change === "increase") {
    if (minute === 59) {
      value = 0;
    } else {
      value = minute + 1;
    };
  } else if (change === "decrease") {
    if (minute === 0) {
      value = 59;
    } else {
      value = minute - 1;
    };
  };

  return value;
};

export const parseDate = (value) => {
  const date = new Date(value)

  let day = date.getDate();
  let month = date.getMonth() + 1;
  let year = date.getFullYear();

  if (day < 10) {
    day = `0${day}`
  };

  if (month < 10) {
    month = `0${month}`
  };

  return `${year}-${month}-${day}`
};

export const formatDate = (value, format) => {
  const formatArray = value.split("/");

  let formatValue = null;
  if (format === "us") {
    formatValue = `${formatArray[1]}/${formatArray[0]}/${formatArray[2]}`;
  } else if (format === "input") {
    formatValue = `${formatArray[2]}-${formatArray[1]}-${formatArray[0]}`
  };

  return formatValue;
};

export const displayDate = (value) => {
  let day = value.getDate();
  let month = value.getMonth() + 1;
  const year = value.getFullYear();

  if (day < 10) {
    day = `0${day}`
  }
  if (month < 10) {
    month = `0${month}`
  }

  return `${day}/${month}/${year}`
};

let displayMinute = null;
let displayHour = null;
const preFix = 0;

export const hourDisplay = (hour) => {
  // US FORMAT
  // if (format === "us" && "pm") {
  //   hour += 12;
  // }
  // --------

  if (hour < 10) {
    displayHour = `${preFix}${hour}`;
  } else {
    displayHour = hour;
  };

  return displayHour;
};

export const minuteDisplay = (minute) => {
  if (minute < 10) {
    displayMinute = `${preFix}${minute}`;
  } else {
    displayMinute = minute;
  };

  return displayMinute;
};
