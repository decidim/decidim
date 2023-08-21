/* eslint-disable require-jsdoc */
import icon from "src/decidim/redesigned_icon"

export default function generateTimePicker(input, row) {
  const timeColumn = document.createElement("div");
  timeColumn.setAttribute("class", "time_column");

  const time = document.createElement("input");
  time.setAttribute("id", `${input.id}_time`);
  time.setAttribute("class", "timepicker");
  time.setAttribute("placeholder", "hh:mm")
  time.setAttribute("type", "text");

  const clock = document.createElement("button");
  clock.innerHTML = icon("time-line", {class: "w-6 h-6"})
  clock.setAttribute("class", "clock_button");

  timeColumn.appendChild(time);
  timeColumn.appendChild(clock);

  row.append(timeColumn);

  const hourColumn = document.createElement("div");
  hourColumn.setAttribute("class", "hour_column");

  const hours = document.createElement("input");
  hours.setAttribute("class", "hourpicker");
  hours.setAttribute("readonly", "true");
  hours.setAttribute("min", 0)

  const hourUp = document.createElement("button");
  hourUp.setAttribute("class", "hourup");
  hourUp.innerHTML = icon("arrow-drop-up-line", {class: "w-5 h-5"});

  const hourDown = document.createElement("button");
  hourDown.setAttribute("class", "hourdown");
  hourDown.innerHTML = icon("arrow-drop-down-line", {class: "w-5 h-5"});

  hourColumn.appendChild(hours);
  hourColumn.appendChild(hourUp);
  hourColumn.appendChild(hourDown);

  const minuteColumn = document.createElement("div");
  minuteColumn.setAttribute("class", "minute_column");

  const minutes = document.createElement("input");
  minutes.setAttribute("class", "minutepicker");
  minutes.setAttribute("readonly", "true");

  const minuteUp = document.createElement("button");
  minuteUp.setAttribute("class", "minuteup");
  minuteUp.innerHTML = icon("arrow-drop-up-line", {class: "w-5 h-5"});

  const minuteDown = document.createElement("button");
  minuteDown.setAttribute("class", "minutedown");
  minuteDown.innerHTML = icon("arrow-drop-down-line", {class: "w-5 h-5"});

  minuteColumn.appendChild(minutes);
  minuteColumn.appendChild(minuteUp);
  minuteColumn.appendChild(minuteDown);

  const timeRow = document.createElement("div");
  timeRow.setAttribute("class", "time_row");

  timeRow.appendChild(hourColumn);
  timeRow.appendChild(minuteColumn);

  const hourLabel = document.createElement("span");
  hourLabel.setAttribute("class", "hour_label");
  hourLabel.innerText = "Hour";

  const hourLabelContainer = document.createElement("div");
  hourLabelContainer.setAttribute("class", "hour_label_container");

  hourLabelContainer.appendChild(hourLabel);

  const minuteLabel = document.createElement("span");
  minuteLabel.setAttribute("class", "minute_label");
  minuteLabel.innerText = "Minute";

  const minuteLabelContainer = document.createElement("div");
  minuteLabelContainer.setAttribute("class", "minute_label_container");

  minuteLabelContainer.appendChild(minuteLabel);

  const labels = document.createElement("div");
  labels.setAttribute("class", "label_row");

  labels.appendChild(hourLabelContainer);
  labels.appendChild(minuteLabelContainer);

  const timePicker = document.createElement("div");
  timePicker.setAttribute("id", `${time.id}_timepicker`);
  timePicker.setAttribute("class", "clock");
  timePicker.style.display = "none";

  timePicker.appendChild(timeRow)
  timePicker.appendChild(labels);

  const closeClock = document.createElement("button");
  closeClock.innerText = "Close";
  closeClock.setAttribute("class", "close_clock");

  const resetClock = document.createElement("button");
  resetClock.innerText = "Reset";
  resetClock.setAttribute("class", "reset_clock");

  timePicker.appendChild(closeClock);
  timePicker.appendChild(resetClock);

  time.after(timePicker);

  time.addEventListener("focus", () => {
    timePicker.style.display = "none";
  })

  const timePickerDisplay = (event) => {
    if (!timeColumn.contains(event.target)) {
      timePicker.style.display = "none";
      document.removeEventListener("click", timePickerDisplay)
    }
  };

  let hour = 0;
  let minute = 0;
  let displayMinute = null;
  let displayHour = null;
  const preFix = 0;

  const display = (element) => {
    if (hour < 10) {
      displayHour = `${preFix}${hour}`;
    } else {
      displayHour = hour;
    };

    if (minute < 10) {
      displayMinute = `${preFix}${minute}`;
    } else {
      displayMinute = minute;
    };

    if (element === "clock") {
      hours.value = displayHour;
      minutes.value = displayMinute;
    } else if (element === "input") {
      time.value = `${displayHour}:${displayMinute}`;
    } else {
      hours.value = displayHour;
      minutes.value = displayMinute;
      time.value = `${displayHour}:${displayMinute}`;
    };
  };

  display("clock");

  const changeDisplay = (change, target) => {
    if (target === "hour") {
      if (change === "increase") {
        if (hour === 23) {
          hour = 0;
        } else {
          hour += 1;
        };
      } else if (change === "decrease") {
        if (hour === 0) {
          hour = 23;
        } else {
          hour -= 1;
        };
      };
    };
    if (target === "minute") {
      if (change === "increase") {
        if (minute === 59) {
          minute = 0;
        } else {
          minute += 1;
        };
      } else if (change === "decrease") {
        if (minute === 0) {
          minute = 59;
        } else {
          minute -= 1;
        };
      };
    };
    display();
  };

  time.addEventListener("paste", (event) => {
    event.preventDefault();
    const value = event.clipboardData.getData("text/plain");

    if ((/^([0-9]|0[0-9]|1[0-9]|2[0-3])(.|:)[0-5][0-9]$/).test(value)) {
      if ((/(^[0-9])(.|:)[0-5][0-9]$/).test(value)) {
        hour = Number(value[0]);
        minute = Number(`${value[2]}${value[3]}`);
      } else if ((/(^0[0-9])(.|:)[0-5][0-9]$/).test(value)) {
        hour = Number(value[1]);
        minute = Number(`${value[3]}${value[4]}`);
      } else {
        hour = Number(`${value[0]}${value[1]}`);
        minute = Number(`${value[3]}${value[4]}`);
      }
      display();
    }
  });

  time.addEventListener("keydown", (event) => {
    const selectionStart = [1, 2, 3];
    const inputLength = [4, 5];

    switch (event.key) {
    case "ArrowUp":
      break;
    case "ArrowDown":
      break;
    case "ArrowLeft":
      break;
    case "ArrowRight":
      break;
    case "Backspace":
      if (inputLength.includes(time.value.length) && selectionStart.includes(event.target.selectionStart)) {
        event.preventDefault();
      } else if (time.value.length === 4) {
        time.value = time.value.replace(":", "");
      };

      break;
    case "Tab":
      break;
    default:
      if ((/[0-9]/).test(event.key)) {
        break;
      } else if (event.ctrlKey === true || event.altKey === true) {
        break;
      } else {
        event.preventDefault();
      };
    };
  });

  time.addEventListener("beforeinput", (event) => {
    if (time.value.length === 2 && event.inputType === "insertText") {
      time.value += ":";
    };

    if (time.value.length >= 5 && event.inputType === "insertText") {
      event.preventDefault();
    };
  });

  time.addEventListener("keyup", () => {
    if (time.value.length === 5) {
      if (time.value[0] === "0") {
        hour = Number(time.value[1]);
      } else {
        hour = Number(`${time.value[0]}${time.value[1]}`);
      };

      if (time.value[3] === "0") {
        minute = Number(time.value[4]);
      } else {
        minute = Number(`${time.value[3]}${time.value[4]}`);
      };
    };
    display("clock");
  });

  resetClock.addEventListener("click", (event) => {
    event.preventDefault();
    hour = 0;
    minute = 0;
    display("clock");
  });

  closeClock.addEventListener("click", (event) => {
    event.preventDefault();
    timePicker.style.display = "none";
  });

  clock.addEventListener("click", (event) => {
    event.preventDefault();
    timePicker.style.display = "block";

    document.addEventListener("click", timePickerDisplay);
  });

  hourUp.addEventListener("click", (event) => {
    event.preventDefault();
    changeDisplay("increase", "hour");
  });

  hourDown.addEventListener("click", (event) => {
    event.preventDefault();
    changeDisplay("decrease", "hour");
  });

  minuteUp.addEventListener("click", (event) => {
    event.preventDefault();
    changeDisplay("increase", "minute");
  });

  minuteDown.addEventListener("click", (event) => {
    event.preventDefault();
    changeDisplay("decrease", "minute");
  });
};
