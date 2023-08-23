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
