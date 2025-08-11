/* eslint-disable require-jsdoc */
import icon from "src/decidim/icon"
import { changeHourDisplay, changeMinuteDisplay, formatDate, hourDisplay, minuteDisplay, formatTime, setHour, setMinute, updateTimeValue, updateInputValue } from "src/decidim/datepicker/datepicker_functions"
import { timeKeyDownListener, timeBeforeInputListener } from "src/decidim/datepicker/datepicker_listeners";
import { getDictionary } from "src/decidim/i18n";

export default function generateTimePicker(input, row, formats) {
  const i18n = getDictionary("time.buttons");

  const timeColumn = document.createElement("div");
  timeColumn.setAttribute("class", "datepicker__time-column");

  const time = document.createElement("input");
  time.setAttribute("id", `${input.id}_time`);
  time.setAttribute("type", "text");
  time.setAttribute("aria-label", input.dataset.timeLabel);

  const clock = document.createElement("button");
  clock.innerHTML = icon("time-line")
  clock.setAttribute("class", "datepicker__clock-button");
  clock.setAttribute("type", "button");
  clock.setAttribute("aria-label", input.dataset.buttonTimeLabel);

  timeColumn.appendChild(time);
  timeColumn.appendChild(clock);

  row.append(timeColumn);

  const hourColumn = document.createElement("div");
  hourColumn.setAttribute("class", "datepicker__hour-column");

  const hours = document.createElement("input");
  hours.setAttribute("class", "datepicker__hour-picker");
  hours.setAttribute("readonly", "true");
  hours.setAttribute("disabled", "true");

  const hourUp = document.createElement("button");
  hourUp.setAttribute("class", "datepicker__hour-up");
  hourUp.innerHTML = icon("arrow-drop-up-line", {class: "w-10 h-6 pr-1"});
  hourUp.setAttribute("type", "button");

  const hourDown = document.createElement("button");
  hourDown.setAttribute("class", "datepicker__hour-down");
  hourDown.innerHTML = icon("arrow-drop-down-line", {class: "w-10 h-6 pr-1"});
  hourDown.setAttribute("type", "button");

  hourColumn.appendChild(hours);
  hourColumn.appendChild(hourUp);
  hourColumn.appendChild(hourDown);

  const minuteColumn = document.createElement("div");
  minuteColumn.setAttribute("class", "datepicker__minute-column");

  const minutes = document.createElement("input");
  minutes.setAttribute("class", "datepicker__minute-picker");
  minutes.setAttribute("readonly", "true");
  minutes.setAttribute("disabled", "true");

  const minuteUp = document.createElement("button");
  minuteUp.setAttribute("class", "datepicker__minute-up");
  minuteUp.innerHTML = icon("arrow-drop-up-line", {class: "w-10 h-6 pr-1"});
  minuteUp.setAttribute("type", "button");

  const minuteDown = document.createElement("button");
  minuteDown.setAttribute("class", "datepicker__minute-down");
  minuteDown.innerHTML = icon("arrow-drop-down-line", {class: "w-10 h-6 pr-1"});
  minuteDown.setAttribute("type", "button");

  minuteColumn.appendChild(minutes);
  minuteColumn.appendChild(minuteUp);
  minuteColumn.appendChild(minuteDown);

  const timeRow = document.createElement("div");
  timeRow.setAttribute("class", "datepicker__time-row");

  timeRow.appendChild(hourColumn);
  timeRow.appendChild(minuteColumn);


  // US FORMAT

  if (formats.time === 12) {
    const periodColumn = document.createElement("div");
    periodColumn.setAttribute("class", "datepicker__period-column");

    const periodAm = document.createElement("input");
    periodAm.setAttribute("type", "radio");
    periodAm.setAttribute("name", `period_${input.id}`);
    periodAm.setAttribute("id", `period_am_${input.id}`);
    periodAm.setAttribute("class", "datepicker__period-am");
    const periodAmLabel = document.createElement("span");
    periodAmLabel.innerText = "AM"

    const periodPm = document.createElement("input");
    periodPm.setAttribute("type", "radio");
    periodPm.setAttribute("name", `period_${input.id}`);
    periodPm.setAttribute("id", `period_pm_${input.id}`);
    periodPm.setAttribute("class", "datepicker__period-pm");
    const periodPmLabel = document.createElement("span");
    periodPmLabel.innerText = "PM"

    periodColumn.appendChild(periodAm);
    periodColumn.appendChild(periodAmLabel);
    periodColumn.appendChild(periodPm);
    periodColumn.appendChild(periodPmLabel);
    timeColumn.appendChild(periodColumn);

    periodAm.addEventListener("click", () => {
      input.value = `${formatDate(document.querySelector(`#${input.id}_date`).value, formats)}T${formatTime(time.value, formats.time, input.id)}`;
    });

    periodPm.addEventListener("click", () => {
      input.value = `${formatDate(document.querySelector(`#${input.id}_date`).value, formats)}T${formatTime(time.value, formats.time, input.id)}`;
    });
  };

  const hourLabel = document.createElement("span");
  hourLabel.innerText = "Hour";

  const hourLabelContainer = document.createElement("div");
  hourLabelContainer.setAttribute("class", "datepicker__hour-label-container");

  hourLabelContainer.appendChild(hourLabel);

  const minuteLabel = document.createElement("span");
  minuteLabel.innerText = "Minute";

  const minuteLabelContainer = document.createElement("div");
  minuteLabelContainer.setAttribute("class", "datepicker__minute-label-container");

  minuteLabelContainer.appendChild(minuteLabel);

  const labels = document.createElement("div");
  labels.setAttribute("class", "datepicker__label-row");

  labels.appendChild(hourLabelContainer);
  labels.appendChild(minuteLabelContainer);

  const timePicker = document.createElement("div");
  timePicker.setAttribute("id", `${time.id}_timepicker`);
  timePicker.setAttribute("class", "datepicker__time-frame");
  timePicker.style.display = "none";

  timePicker.appendChild(timeRow);
  timePicker.appendChild(labels);

  const closeClock = document.createElement("button");
  closeClock.innerText = i18n.close;
  closeClock.setAttribute("class", "datepicker__close-clock button button__transparent-secondary button__xs");
  closeClock.setAttribute("type", "button");

  const resetClock = document.createElement("button");
  resetClock.innerText = i18n.reset;
  resetClock.setAttribute("class", "datepicker__reset-clock button button__xs button__text-secondary");
  resetClock.setAttribute("type", "button");

  const selectClock = document.createElement("button");
  selectClock.innerText = i18n.select;
  selectClock.setAttribute("class", "datepicker__select-clock button button__secondary button__xs");
  selectClock.setAttribute("type", "button");

  timePicker.appendChild(resetClock);
  timePicker.appendChild(selectClock);
  timePicker.appendChild(closeClock);

  clock.after(timePicker);

  const timePickerDisplay = (event) => {
    if (!timeColumn.contains(event.target)) {
      timePicker.style.display = "none";
      document.removeEventListener("click", timePickerDisplay)
    }
  };

  let hour = 0;

  if (formats.time === 12) {
    hour = 1;
  };

  let minute = 0;

  if (input.value !== "") {
    hour = setHour(input.value.split("T")[1], formats.time);
    minute = setMinute(input.value.split("T")[1]);
  };

  time.addEventListener("focus", () => {
    timePicker.style.display = "none";
  })

  time.addEventListener("paste", (event) => {
    event.preventDefault();
    const value = event.clipboardData.getData("text/plain");

    let formatGuard = (/^([0-9]|0[0-9]|1[0-9]|2[0-3])(.|:)[0-5][0-9]/).test(value);

    if (formats.time === 12) {
      formatGuard = (/^([0-9]|0[0-9]|1[0-2])(.|:)[0-5][0-9]/).test(value);
    };

    if (formatGuard) {
      if ((/(^[0-9])(.|:)[0-5][0-9]/).test(value)) {
        hour = Number(value[0]);
        minute = Number(`${value[2]}${value[3]}`);
      } else if ((/(^0[0-9])(.|:)[0-5][0-9]/).test(value)) {
        hour = Number(value[1]);
        minute = Number(`${value[3]}${value[4]}`);
      } else {
        hour = Number(`${value[0]}${value[1]}`);
        minute = Number(`${value[3]}${value[4]}`);
      }
      hours.value = hourDisplay(hour);
      minutes.value = minuteDisplay(minute);
      time.value = `${hourDisplay(hour)}:${minuteDisplay(minute)}`;
      input.value = `${formatDate(document.querySelector(`#${input.id}_date`).value, formats)}T${formatTime(time.value, formats.time, input.id)}`;
    }
  });

  timeKeyDownListener(time);
  timeBeforeInputListener(time);

  time.addEventListener("keyup", () => {
    if (time.value.length === 5) {
      const inputHour = time.value.split(":")[0];
      const inputMinute = time.value.split(":")[1];

      if (formats.time === 12 && Number(inputHour) <= 12 && Number(inputMinute) <= 59 ||
          formats.time === 24 && Number(inputHour) <= 23 && Number(inputMinute) <= 59) {
        hour = Number(inputHour);
        minute = Number(inputMinute);

        hours.value = hourDisplay(hour);
        minutes.value = minuteDisplay(minute);
        input.value = `${formatDate(document.querySelector(`#${input.id}_date`).value, formats)}T${formatTime(time.value, formats.time, input.id)}`;
      };
    } else if (time.value.length === 0) {
      hours.value = "";
      minutes.value = "";
    };
  });

  resetClock.addEventListener("click", (event) => {
    event.preventDefault();
    if (formats.time === 24) {
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

  selectClock.addEventListener("click", (event) => {
    event.preventDefault();
    updateTimeValue(time, hour, minute);
    updateInputValue(input, formats, time);
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
    hour = changeHourDisplay("increase", hour, formats.time);
    hours.value = hourDisplay(hour);
  });

  hourDown.addEventListener("click", (event) => {
    event.preventDefault();
    hour = changeHourDisplay("decrease", hour, formats.time);
    hours.value = hourDisplay(hour);
  });

  minuteUp.addEventListener("click", (event) => {
    event.preventDefault();
    minute = changeMinuteDisplay("increase", minute);
    minutes.value = minuteDisplay(minute);
  });

  minuteDown.addEventListener("click", (event) => {
    event.preventDefault();
    minute = changeMinuteDisplay("decrease", minute);
    minutes.value = minuteDisplay(minute);
  });
};
