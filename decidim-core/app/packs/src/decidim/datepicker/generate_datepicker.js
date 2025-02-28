/* eslint-disable require-jsdoc */
import icon from "src/decidim/icon"
import { dateToPicker, formatDate, displayDate, formatTime, calculateDatepickerPos } from "src/decidim/datepicker/datepicker_functions"
import { dateKeyDownListener, dateBeforeInputListener } from "src/decidim/datepicker/datepicker_listeners"
import { getDictionary } from "src/decidim/i18n"

export default function generateDatePicker(input, row, formats) {
  const i18n = getDictionary("date.buttons");

  const dateColumn = document.createElement("div");
  dateColumn.setAttribute("class", "datepicker__date-column");

  const date = document.createElement("input");
  date.setAttribute("id", `${input.id}_date`);
  date.setAttribute("type", "text");
  date.setAttribute("aria-label", `Enter ${input.id.split("_").join(" ").replace(/\btime\b/, "date")}`);

  const calendar = document.createElement("button");
  calendar.innerHTML = icon("calendar-line");
  calendar.setAttribute("class", "datepicker__calendar-button");
  calendar.setAttribute("type", "button");
  calendar.setAttribute("aria-label", "Open calendar");

  dateColumn.appendChild(date);
  dateColumn.appendChild(calendar);
  row.append(dateColumn);

  const datePickerContainer = document.createElement("div");
  datePickerContainer.setAttribute("class", "datepicker__container");
  datePickerContainer.style.display = "none";

  const datePicker = document.createElement("wc-datepicker");
  datePicker.setAttribute("id", `${date.id}_datepicker`);
  datePicker.setAttribute("locale", `${document.documentElement.getAttribute("lang") || "en"}`);

  datePickerContainer.appendChild(datePicker);

  const closeCalendar = document.createElement("button");
  closeCalendar.innerText = i18n.close;
  closeCalendar.setAttribute("class", "datepicker__close-calendar button button__transparent-secondary button__xs");
  closeCalendar.setAttribute("type", "button");

  const pickCalendar = document.createElement("button");
  pickCalendar.innerText = i18n.select;
  pickCalendar.setAttribute("class", "datepicker__pick-calendar button button__secondary button__xs");
  pickCalendar.setAttribute("disabled", true);
  pickCalendar.setAttribute("type", "button");

  datePickerContainer.appendChild(pickCalendar);
  datePickerContainer.appendChild(closeCalendar);

  dateColumn.appendChild(datePickerContainer);

  let prevDate = null;
  let defaultTime = input.getAttribute("default_time") || "00:00"

  const datePickerDisplay = (event) => {
    if (!dateColumn.contains(event.target)) {
      datePickerContainer.style.display = "none";
      document.removeEventListener("click", datePickerDisplay)
    };
  };

  dateKeyDownListener(date);
  dateBeforeInputListener(date);

  date.addEventListener("paste", (event) => {
    event.preventDefault();
    const value = event.clipboardData.getData("text/plain");
    if ((/^[0-9/.-]+$/).test(value)) {
      date.value = value.replaceAll(/[/.-]/g, formats.separator);

      if (input.type === "date") {
        input.value = `${formatDate(date.value, formats)}`;
      } else if (input.type === "datetime-local") {
        input.value = `${formatDate(date.value, formats)}T${formatTime(document.querySelector(`#${input.id}_time`).value, formats.time, input.id) || defaultTime}`;
      };
    };
  });

  date.addEventListener("focus", () => {
    datePickerContainer.style.display = "none";
  });

  date.addEventListener("keyup", () => {
    if (date.value.length === 10) {
      date.value = date.value.replaceAll(/[/.-]/g, formats.separator);
      prevDate = dateToPicker(date.value, formats);
      if (input.type === "date") {
        input.value = `${formatDate(date.value, formats)}`;
      } else if (input.type === "datetime-local") {
        input.value = `${formatDate(date.value, formats)}T${formatTime(document.querySelector(`#${input.id}_time`).value, formats.time, input.id) || defaultTime}`;
      };
    };
  });

  let pickedDate = null;

  datePicker.addEventListener("selectDate", (event) => {
    pickCalendar.removeAttribute("disabled");
    pickedDate = event.detail;
  });

  pickCalendar.addEventListener("click", (event) => {
    event.preventDefault();

    date.value = displayDate(datePicker.value, formats);
    prevDate = pickedDate;
    if (input.type === "date") {
      input.value = `${pickedDate}`;
    } else if (input.type === "datetime-local") {
      input.value = `${pickedDate}T${formatTime(document.querySelector(`#${input.id}_time`).value, formats.time, input.id) || defaultTime}`;
    };
    datePickerContainer.style.display = "none";
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
    datePickerContainer.style.display = "block";

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
    datePickerContainer.style.display = "none";
  });
};
