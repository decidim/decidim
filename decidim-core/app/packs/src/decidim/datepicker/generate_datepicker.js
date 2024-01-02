/* eslint-disable require-jsdoc */
import icon from "src/decidim/icon"
import { dateToPicker, formatDate, displayDate, formatTime, calculateDatepickerPos } from "src/decidim/datepicker/datepicker_functions"
import { dateKeyDownListener, dateBeforeInputListener } from "src/decidim/datepicker/datepicker_listeners"
import { getDictionary } from "src/decidim/i18n";

export default function generateDatePicker(input, row, formats) {
  const i18n = getDictionary("date.buttons");

  const dateColumn = document.createElement("div");
  dateColumn.setAttribute("class", "date_column");

  const date = document.createElement("input");
  date.setAttribute("id", `${input.id}_date`);
  date.setAttribute("type", "text");

  const calendar = document.createElement("button");
  calendar.innerHTML = icon("calendar-2-fill", {class: "!text-secondary !fill-current !w-6 !h-6"})
  calendar.setAttribute("class", "calendar_button");

  dateColumn.appendChild(date);
  dateColumn.appendChild(calendar);
  row.append(dateColumn);

  const datePicker = document.createElement("wc-datepicker");
  datePicker.setAttribute("id", `${date.id}_datepicker`);
  datePicker.setAttribute("locale", `${document.documentElement.getAttribute("lang") || "en"}`)
  datePicker.style.display = "none";

  const closeCalendar = document.createElement("button");
  closeCalendar.innerText = i18n.close;
  closeCalendar.setAttribute("class", "close_calendar");

  const pickCalendar = document.createElement("button");
  pickCalendar.innerText = i18n.select;
  pickCalendar.setAttribute("class", "pick_calendar");
  pickCalendar.setAttribute("disabled", true);

  datePicker.appendChild(closeCalendar);
  datePicker.appendChild(pickCalendar);

  date.after(datePicker);

  let prevDate = null;
  let defaultTime = input.getAttribute("default_time") || "00:00"

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
      if (formats.date === "%m/%d/%Y") {
        separator = "/";
      };

      if ((/(^[1-9])(-|.|\/)([1-9])(-|.|\/)([0-9]{4})$/).test(value)) {
        date.value = `0${value[0]}${separator}0${value[2]}${separator}${value.substring(value.length - 4)}`;
      } else if ((/(^[1-9])(-|.|\/)([0-2][0-9]|3[0-1])(-|.|\/)([0-9]{4})$/).test(value)) {
        date.value = `0${value[0]}${separator}${value[2]}${value[3]}${separator}${value.substring(value.length - 4)}`;
      } else if ((/([0-2][0-9]|3[0-1])(-|.|\/)([1-9])(-|.|\/)([0-9]{4})$/).test(value)) {
        date.value = `${value[0]}${value[1]}${separator}0${value[3]}${separator}${value.substring(value.length - 4)}`;
      } else {
        date.value = value.replace(/[-./]/g, separator)
      };

      if (input.type === "date") {
        input.value = `${formatDate(date.value, formats.date)}`;
      } else if (input.type === "datetime-local") {
        input.value = `${formatDate(date.value, formats.date)}T${formatTime(document.querySelector(`#${input.id}_time`).value, formats.time, input.id) || defaultTime}`;
      };
    };
  });

  date.addEventListener("focus", () => {
    datePicker.style.display = "none";
  });

  date.addEventListener("focusout", () => {
    if (formats.date === "%d/%m/%Y") {
      date.value = date.value.replaceAll("/", ".");
    } else if (formats.date === "%m/%d/%Y") {
      date.value = date.value.replaceAll(".", "/");
    };
  });

  date.addEventListener("keyup", () => {
    if (date.value.length === 10) {
      prevDate = dateToPicker(date.value, formats.date);
      if (input.type === "date") {
        input.value = `${formatDate(date.value, formats.date)}`;
      } else if (input.type === "datetime-local") {
        input.value = `${formatDate(date.value, formats.date)}T${formatTime(document.querySelector(`#${input.id}_time`).value, formats.time, input.id) || defaultTime}`;
      };
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

    date.value = displayDate(datePicker.value, formats.date);
    prevDate = pickedDate;
    if (input.type === "date") {
      input.value = `${pickedDate}`;
    } else if (input.type === "datetime-local") {
      input.value = `${pickedDate}T${formatTime(document.querySelector(`#${input.id}_time`).value, formats.time, input.id) || defaultTime}`;
    };
    datePicker.style.display = "none";
    pickCalendar.setAttribute("disabled", true);
  });

  calendar.addEventListener("click", (event) => {
    event.preventDefault();

    if (input.value !== "") {
      if (input.type === "date") {
        prevDate = input.value;
      } else if (input.type === "datetime-local") {
        prevDate = input.value.split("T")[0];
      };
    };

    if (prevDate !== null && new Date(prevDate).toString() !== "Invalid Date") {
      datePicker.value = new Date(prevDate);
    };
    pickedDate = null;
    pickCalendar.setAttribute("disabled", true);
    datePicker.style.display = "block";

    document.addEventListener("click", datePickerDisplay);

    if (document.querySelector(".item__edit-sticky")) {
      const datePickerPos = calculateDatepickerPos(datePicker)
      if (datePickerPos < 0) {
        const layoutWrapper = document.querySelector(".layout-wrapper");

        layoutWrapper.style.height = `${layoutWrapper.clientHeight - datePickerPos}px`
      };
    };
  });

  closeCalendar.addEventListener("click", (event) => {
    event.preventDefault();
    datePicker.style.display = "none";
  });
};
