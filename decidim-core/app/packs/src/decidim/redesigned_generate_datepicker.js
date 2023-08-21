/* eslint-disable require-jsdoc */
import icon from "src/decidim/redesigned_icon"

export default function generateDatePicker(input, row) {
  const dateColumn = document.createElement("div");
  dateColumn.setAttribute("class", "date_column");

  const date = document.createElement("input");
  date.setAttribute("id", `${input.id}_date`);
  date.setAttribute("class", "datepicker");
  date.setAttribute("type", "date");

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

  date.addEventListener("focus", () => {
    datePicker.style.display = "none";
  });

  date.addEventListener("change", () => {
    if (date.value === "") {
      date.value = prevDate;
    } else {
      datePicker.value = new Date(date.value);
      prevDate = date.value;
    };
  });

  let pickedDate = null;

  datePicker.addEventListener("changeMonth", () => {
    pickCalendar.setAttribute("disabled", true);
    pickedDate = null;
    datePicker.value = pickedDate;
  })

  datePicker.addEventListener("selectDate", (event) => {
    pickCalendar.removeAttribute("disabled");
    pickedDate = event.detail;
  });

  pickCalendar.addEventListener("click", (event) => {
    event.preventDefault();

    date.value = pickedDate;
    prevDate = pickedDate;
    datePicker.style.display = "none";
    pickCalendar.setAttribute("disabled", true);
  });

  const datePickerDisplay = (event) => {
    if (!dateColumn.contains(event.target)) {
      datePicker.style.display = "none";
      document.removeEventListener("click", datePickerDisplay)
    };
  };

  calendar.addEventListener("click", (event) => {
    event.preventDefault();
    if (prevDate === null) {
      datePicker.value = prevDate;
    } else {
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
