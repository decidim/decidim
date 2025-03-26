// Utility helper functions for the date and time picker functionality

export const setHour = (value, format) => {
  const hour = value.split(":")[0];
  if (format === 12) {
    if (Number(hour) > 12) {
      return Number(hour) - 12;
    };

    if (Number(hour) === 0) {
      return 12;
    };

    return Number(hour);
  };

  return Number(hour);
};

export const setMinute = (value) => {
  const minute = value.split(":")[1];

  return Number(minute);
};

export const formatInputDate = (date, formats) => {
  const dateList = date.split("-");
  const year = dateList[0];
  const month = dateList[1];
  const day = dateList[2];

  if (formats.order === "m-d-y") {
    return `${month}${formats.separator}${day}${formats.separator}${year}`;
  } else if (formats.order === "y-m-d") {
    return `${year}${formats.separator}${month}${formats.separator}${day}`;
  };
  return `${day}${formats.separator}${month}${formats.separator}${year}`;
};

export const formatInputTime = (time, format, input) => {
  const timeList = time.split(":");
  let hour = timeList[0];
  const minute = timeList[1];

  if (format === 12) {
    if (Number(hour) === 12) {
      document.getElementById(`period_pm_${input.id}`).checked = true;
    } else if (Number(hour) > 12 && Number(hour) < 22) {
      hour = `0${Number(hour) - 12}`;
      document.getElementById(`period_pm_${input.id}`).checked = true;
    } else if (Number(hour) >= 22) {
      hour = `${Number(hour) - 12}`;
      document.getElementById(`period_pm_${input.id}`).checked = true;
    } else if (Number(hour) === 0) {
      hour = "12";
    }

    return `${hour}:${minute}`;
  };

  return time;
};

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

export const updateTimeValue = (time, hour, minute) => {
  time.value = `${hourDisplay(hour)}:${minuteDisplay(minute)}`;
};

export const formatDate = (value, formats) => {
  let newValue = value;
  const splitValue = value.split(formats.separator);

  if (formats.order === "d-m-y") {
    newValue = `${splitValue[1]}/${splitValue[0]}/${splitValue[2]}`;
  } else if (formats.order === "y-m-d") {
    newValue = `${splitValue[1]}/${splitValue[2]}/${splitValue[0]}`
  };

  const date = new Date(newValue)

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

export const formatTime = (value, format, inputname) => {
  if (format === 12) {
    const splitValue = value.split(":");
    let hour = splitValue[0];
    const minute = splitValue[1];
    if (document.getElementById(`period_am_${inputname}`).checked) {
      switch (hour) {
      case "12":
        hour = "00";

        return `${hour}:${minute}`;
      default:
        return value;
      };
    } else if (document.getElementById(`period_pm_${inputname}`).checked) {
      if (Number(hour) > 0 && Number(hour) < 12) {
        hour = `${Number(hour) + 12}`;
      };

      return `${hour}:${minute}`
    };
  };

  return value;
};

export const updateInputValue = (input, formats, time) => {
  input.value = `${formatDate(document.querySelector(`#${input.id}_date`).value, formats)}T${formatTime(time.value, formats.time, input.id)}`;
};

export const dateToPicker = (value, formats) => {
  let formatArray = value.split(formats.separator);
  let formatValue = value;

  if (formats.order === "d-m-y") {
    formatValue = `${formatArray[1]}/${formatArray[0]}/${formatArray[2]}`;
  } else if (formats.order === "y-m-d") {
    formatValue = `${formatArray[1]}/${formatArray[2]}/${formatArray[0]}`;
  };


  return formatValue;
};

export const displayDate = (value, formats) => {
  let day = value.getDate();
  let month = value.getMonth() + 1;
  const year = value.getFullYear();

  if (day < 10) {
    day = `0${day}`
  }
  if (month < 10) {
    month = `0${month}`
  }

  if (formats.order === "d-m-y") {
    return `${day}${formats.separator}${month}${formats.separator}${year}`
  } else if (formats.order === "y-m-d") {
    return `${year}${formats.separator}${month}${formats.separator}${day}`
  };

  return `${month}${formats.separator}${day}${formats.separator}${year}`;
};

export const calculateDatepickerPos = (datePicker) => {
  return (document.body.clientHeight - (datePicker.getBoundingClientRect().top + window.scrollY)) -
  (document.querySelector(".item__edit-sticky").clientHeight + datePicker.clientHeight)
};
