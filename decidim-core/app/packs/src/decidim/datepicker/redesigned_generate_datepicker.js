/* eslint-disable require-jsdoc */
import icon from "src/decidim/redesigned_icon"
import { formatDate, displayDate, formatTime } from "./redesigned_datepicker_functions"
import { dateKeyDownListener, dateBeforeInputListener } from "./redesigned_datepicker_listeners"

export default function generateDatePicker(input, row, format) {
  const dateColumn = document.createElement("div");
  dateColumn.setAttribute("class", "date_column");

  const date = document.createElement("input");
  date.setAttribute("id", `${input.id}_date`);
  date.setAttribute("class", "datepicker");
  date.setAttribute("type", "text");

  const placeholder = format

  date.setAttribute("placeholder", placeholder);

  const calendar = document.createElement("button");
  calendar.innerHTML = icon("calendar-2-fill", {class: "w-6 h-6"})
  calendar.setAttribute("class", "calendar_button");

  dateColumn.appendChild(date);
  dateColumn.appendChild(calendar);
  row.append(dateColumn);

  const datePicker = document.createElement("wc-datepicker");
  datePicker.setAttribute("id", `${date.id}_datepicker`);
  datePicker.style.display = "none";

  const closeCalendar = document.createElement("button");
  closeCalendar.innerText = "Close";
  closeCalendar.setAttribute("class", "close_calendar");

  const pickCalendar = document.createElement("button");
  pickCalendar.innerText = "Select";
  pickCalendar.setAttribute("class", "pick_calendar");
  pickCalendar.setAttribute("disabled", true);

  datePicker.appendChild(closeCalendar);
  datePicker.appendChild(pickCalendar);

  date.after(datePicker);

  let prevDate = null;

  const datePickerDisplay = (event) => {
    if (!dateColumn.contains(event.target)) {
      datePicker.style.display = "none";
      document.removeEventListener("click", datePickerDisplay)
    };
  };

  dateKeyDownListener(date);
  dateBeforeInputListener(date);

  date.addEventListener("paste", (event) => {
    event.preventDefault();
    const value = event.clipboardData.getData("text/plain");
    if ((/^([1-9]|[0-2][0-9]|3[0-1])(-|.|\/)([1-9]|[0-2][0-9]|3[0-1])(-|.|\/)([0-9]{4})$/).test(value)) {
      let separator = ".";
      if (format === "%m/%d/%Y") {
        separator = "/";
      };

      if ((/(^[1-9])(-|.|\/)([1-9])(-|.|\/)([0-9]{4})$/).test(value)) {
        date.value = `0${value[0]}${separator}0${value[2]}${separator}${value.substring(value.length - 4)}`;
      } else if ((/(^[1-9])(-|.|\/)([0-2][0-9]|3[0-1])(-|.|\/)([0-9]{4})$/).test(value)) {
        date.value = `0${value[0]}${separator}${value[2]}${value[3]}${separator}${value.substring(value.length - 4)}`;
      } else if ((/([0-2][0-9]|3[0-1])(-|.|\/)([1-9])(-|.|\/)([0-9]{4})$/).test(value)) {
        date.value = `${value[0]}${value[1]}${separator}0${value[3]}${separator}${value.substring(value.length - 4)}`;
      } else {
        date.value = value.replace(/[-/]/g, ".")

        if (format === "%m/%d/%Y") {
          date.value = value.replace(/[-.]/g, "/");
        };
      };

      input.value = `${formatDate(date.value, "input", format)}T${formatTime(document.querySelector(`#${input.id}_time`).value)}`;
    };
  });

  date.addEventListener("focus", () => {
    datePicker.style.display = "none";
  });

  date.addEventListener("keyup", () => {
    if (date.value.length === 10) {
      prevDate = formatDate(date.value, "datepicker", format);
      input.value = `${formatDate(date.value, "input", format)}T${formatTime(document.querySelector(`#${input.id}_time`).value)}`;
    };
  });

  let pickedDate = null;

  datePicker.addEventListener("changeMonth", () => {
    pickCalendar.setAttribute("disabled", true);
    if (pickedDate !== null) {
      pickedDate = null;
      datePicker.value = pickedDate;
    }
  })

  datePicker.addEventListener("selectDate", (event) => {
    pickCalendar.removeAttribute("disabled");
    pickedDate = event.detail;
  });

  pickCalendar.addEventListener("click", (event) => {
    event.preventDefault();

    date.value = displayDate(datePicker.value, format);
    prevDate = pickedDate;
    input.value = `${pickedDate}T${formatTime(document.querySelector(`#${input.id}_time`).value)}`;
    datePicker.style.display = "none";
    pickCalendar.setAttribute("disabled", true);
  });

  calendar.addEventListener("click", (event) => {
    event.preventDefault();

    if (input.value !== "") {
      prevDate = input.value.split("T")[0];
    }
    if (prevDate !== null && new Date(prevDate).toString() !== "Invalid Date") {
      datePicker.value = new Date(prevDate);
    };
    pickedDate = null;
    pickCalendar.setAttribute("disabled", true);
    datePicker.style.display = "block";

    document.addEventListener("click", datePickerDisplay);
  });

  closeCalendar.addEventListener("click", (event) => {
    event.preventDefault();
    datePicker.style.display = "none";
  });
};
