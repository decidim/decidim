/* eslint-disable require-jsdoc */
import icon from "src/decidim/redesigned_icon"
import { changeHourDisplay, changeMinuteDisplay, parseDate, hourDisplay, minuteDisplay, formatTime, setHour, setMinute } from "./redesigned_datepicker_functions"
import { timeKeyDownListener, timeBeforeInputListener } from "./redesigned_datepicker_listeners";

export default function generateTimePicker(input, row, format) {
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


  // US FORMAT

  if (format === 12) {
    const periodColumn = document.createElement("div");
    periodColumn.setAttribute("class", "period_column");

    const periodAm = document.createElement("input");
    periodAm.setAttribute("type", "radio");
    periodAm.setAttribute("name", `period_${input.id}`);
    periodAm.setAttribute("id", `period_am_${input.id}`);
    periodAm.setAttribute("class", "period_am");
    const periodAmLabel = document.createElement("span");
    periodAmLabel.innerText = "AM"

    const periodPm = document.createElement("input");
    periodPm.setAttribute("type", "radio");
    periodPm.setAttribute("name", `period_${input.id}`);
    periodPm.setAttribute("id", `period_pm_${input.id}`);
    periodPm.setAttribute("class", "period_pm");
    const periodPmLabel = document.createElement("span");
    periodPmLabel.innerText = "PM"

    periodColumn.appendChild(periodAm);
    periodColumn.appendChild(periodAmLabel);
    periodColumn.appendChild(periodPm);
    periodColumn.appendChild(periodPmLabel);
    timeColumn.appendChild(periodColumn);

    periodAm.addEventListener("click", () => {
      input.value = `${parseDate(document.querySelector(`#${input.id}_date`).value)}T${formatTime(time.value, format, input.id)}`;
    });

    periodPm.addEventListener("click", () => {
      input.value = `${parseDate(document.querySelector(`#${input.id}_date`).value)}T${formatTime(time.value, format, input.id)}`;
    });
  };

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
  timePicker.setAttribute("class", "time_frame");
  timePicker.style.display = "none";

  timePicker.appendChild(timeRow);
  timePicker.appendChild(labels);

  const closeClock = document.createElement("button");
  closeClock.innerText = "Done";
  closeClock.setAttribute("class", "close_clock");

  const resetClock = document.createElement("button");
  resetClock.innerText = "Reset";
  resetClock.setAttribute("class", "button button__sm button__text-secondary reset_clock");

  timePicker.appendChild(closeClock);
  timePicker.appendChild(resetClock);

  time.after(timePicker);

  const timePickerDisplay = (event) => {
    if (!timeColumn.contains(event.target)) {
      timePicker.style.display = "none";
      document.removeEventListener("click", timePickerDisplay)
    }
  };

  let hour = 0;

  if (format === 12) {
    hour = 1;
  };

  let minute = 0;

  if (input.value !== "") {
    hour = setHour(input.value.split("T")[1], format);
    minute = setMinute(input.value.split("T")[1]);
  };

  time.addEventListener("focus", () => {
    timePicker.style.display = "none";
  })

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
      hours.value = hourDisplay(hour);
      minutes.value = minuteDisplay(minute);
      time.value = `${hourDisplay(hour)}:${minuteDisplay(minute)}`;
      input.value = `${parseDate(document.querySelector(`#${input.id}_date`).value)}T${formatTime(time.value, format, input.id)}`;
    }
  });

  timeKeyDownListener(time);
  timeBeforeInputListener(time);

  time.addEventListener("keyup", () => {
    if (time.value.length === 5) {
      const inputHour = time.value.split(":")[0];
      const inputMinute = time.value.split(":")[1];

      if (format === 12 && Number(inputHour) <= 12 && Number(inputMinute) <= 59 ||
          format === 24 && Number(inputHour) <= 23 && Number(inputMinute) <= 59) {
        hour = Number(inputHour);
        minute = Number(inputMinute);

        hours.value = hourDisplay(hour);
        minutes.value = minuteDisplay(minute);
        input.value = `${parseDate(document.querySelector(`#${input.id}_date`).value)}T${formatTime(time.value, format, input.id)}`;
      };
    } else if (time.value.length === 0) {
      hours.value = "";
      minutes.value = "";
    };
  });

  resetClock.addEventListener("click", (event) => {
    event.preventDefault();
    if (format === 24) {
      hour = 0;
    } else {
      hour = 1;
    }
    minute = 0;

    hours.value = hourDisplay(hour);
    minutes.value = minuteDisplay(minute);
    time.value = "";
  });

  closeClock.addEventListener("click", (event) => {
    event.preventDefault();
    timePicker.style.display = "none";
  });

  clock.addEventListener("click", (event) => {
    event.preventDefault();
    timePicker.style.display = "block";
    document.addEventListener("click", timePickerDisplay);
    hours.value = hourDisplay(hour);
    minutes.value = minuteDisplay(minute);
  });

  hourUp.addEventListener("click", (event) => {
    event.preventDefault();
    hour = changeHourDisplay("increase", hour, format);
    hours.value = hourDisplay(hour);
    time.value = `${hourDisplay(hour)}:${minuteDisplay(minute)}`;
    input.value = `${parseDate(document.querySelector(`#${input.id}_date`).value)}T${formatTime(time.value, format, input.id)}`;
  });

  hourDown.addEventListener("click", (event) => {
    event.preventDefault();
    hour = changeHourDisplay("decrease", hour, format);
    hours.value = hourDisplay(hour);
    time.value = `${hourDisplay(hour)}:${minuteDisplay(minute)}`;
    input.value = `${parseDate(document.querySelector(`#${input.id}_date`).value)}T${formatTime(time.value, format, input.id)}`;
  });

  minuteUp.addEventListener("click", (event) => {
    event.preventDefault();
    minute = changeMinuteDisplay("increase", minute);
    minutes.value = minuteDisplay(minute);
    time.value = `${hourDisplay(hour)}:${minuteDisplay(minute)}`;
    input.value = `${parseDate(document.querySelector(`#${input.id}_date`).value)}T${formatTime(time.value, format, input.id)}`;
  });

  minuteDown.addEventListener("click", (event) => {
    event.preventDefault();
    minute = changeMinuteDisplay("decrease", minute);
    minutes.value = minuteDisplay(minute);
    time.value = `${hourDisplay(hour)}:${minuteDisplay(minute)}`;
    input.value = `${parseDate(document.querySelector(`#${input.id}_date`).value)}T${formatTime(time.value, format, input.id)}`;
  });
};
