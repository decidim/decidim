/* eslint-disable require-jsdoc */

export const changeHourDisplay = (change, hour, format) => {
  let value = null;

  if (change === "increase") {
    if (format === 24) {
      if (hour === 23) {
        value = 0;
      } else {
        value = hour + 1;
      };
    } else if (format === 12) {
      if (hour === 12) {
        value = 1;
      } else {
        value = hour + 1;
      }
    }
  } else if (change === "decrease") {
    if (format === 24) {
      if (hour === 0) {
        value = 23;
      } else {
        value = hour - 1;
      };
    } else if (format === 12) {
      if (hour === 1) {
        value = 12;
      } else {
        value = hour - 1;
      }
    }
  };

  return value;
};

export const changeMinuteDisplay = (change, minute, format) => {
  let value = null;

  if (change === "increase") {
    if (format === 12) {
      if (minute === 59) {
        value = 0;
      } else {
        value = minute + 1;
      };
    }
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

export const formatDate = (value, type, format) => {
  const formatArray = value.split("/");

  let formatValue = null;
  if (type === "datepicker" && format === 24) {
    formatValue = `${formatArray[1]}/${formatArray[0]}/${formatArray[2]}`;
  } else if (type === "input" && format === 24) {
    formatValue = `${formatArray[2]}-${formatArray[1]}-${formatArray[0]}`
  } else {
    formatValue = `${formatArray[0]}-${formatArray[1]}-${formatArray[2]}`
  }

  return formatValue;
};

export const formatTime = (value, format, inputname) => {
  if (format === 12) {
    if (document.getElementById(`period_am_${inputname}`).checked) {
      return value;
    } else if (document.getElementById(`period_pm_${inputname}`).checked) {
      const splitValue = value.split(":");
      let hour = splitValue[0];
      const minute = splitValue[1];

      switch (hour) {
      case "01":
        hour = "13";

        break;
      case "02":
        hour = "14";

        break;
      case "03":
        hour = "15";

        break;
      case "04":
        hour = "16";

        break;
      case "05":
        hour = "17";

        break;
      case "06":
        hour = "18";

        break;
      case "07":
        hour = "19";

        break;
      case "08":
        hour = "20";

        break;
      case "09":
        hour = "21";

        break;
      case "10":
        hour = "22";

        break;
      case "11":
        hour = "23";

        break;
      case "12":
        hour = "00";

        break;
      default:
        return null;
      }
      return `${hour}:${minute}`
    }
  };

  return value;
};

export const displayDate = (value, format) => {
  let day = value.getDate();
  let month = value.getMonth() + 1;
  const year = value.getFullYear();

  if (day < 10) {
    day = `0${day}`
  }
  if (month < 10) {
    month = `0${month}`
  }

  if (format === 12) {
    return `${month}/${day}/${year}`
  }

  return `${day}/${month}/${year}`;
};

let displayMinute = null;
let displayHour = null;
const preFix = 0;

export const hourDisplay = (hour) => {
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
