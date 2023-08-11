/* eslint-disable require-jsdoc */
import { WcDatepicker } from "wc-datepicker/dist/components/wc-datepicker";
import icon from "src/decidim/redesigned_icon"

const monthify = (month) => {
  const months = [
    "january",
    "february",
    "march",
    "april",
    "may",
    "june",
    "july",
    "august",
    "september",
    "october",
    "november",
    "december"
  ];

  return months.indexOf(month) + 1;
};

export default function redesignedFormDatePicker() {
  customElements.define("wc-datepicker", WcDatepicker);

  const inputs = document.querySelectorAll('input[type="datetime-local"], input[type="datetime"], input[type="date"]');

  inputs.forEach((input) => {
    input.style.display = "none";
    const label = input.closest("label");

    const row = document.createElement("div");
    row.setAttribute("class", "timepicker_row");

    const dateColumn = document.createElement("div");
    dateColumn.setAttribute("class", "date_column");

    const timeColumn = document.createElement("div");
    timeColumn.setAttribute("class", "time_column");

    const date = document.createElement("input");
    date.setAttribute("id", `${input.id}_date`);
    date.setAttribute("class", "datepicker");
    date.setAttribute("type", "date");

    const calendar = document.createElement("button");
    calendar.innerHTML = icon("calendar-2-fill", {class: "w-6 h-6"})
    calendar.setAttribute("class", "calendar_button");

    const time = document.createElement("input");
    time.setAttribute("id", `${input.id}_time`);
    time.setAttribute("class", "timepicker");
    time.setAttribute("type", "time");

    dateColumn.appendChild(date);
    timeColumn.appendChild(time);
    dateColumn.appendChild(calendar);
    row.append(dateColumn, timeColumn);

    const datePicker = document.createElement("wc-datepicker");
    datePicker.setAttribute("id", `${date.id}_datepicker`);
    datePicker.style.display = "none";

    const close = document.createElement("button");
    close.innerHTML = icon("close-line", {class: "w-6 h-6"})
    close.setAttribute("class", "close_button");
    datePicker.appendChild(close);

    if (label) {
      label.after(row);
    } else {
      input.after(row);
    }
    date.after(datePicker);
    setTimeout(() => {
      datePicker.querySelector(".wc-datepicker__header > span").addEventListener("DOMCharacterDataModified", (event) => {
        const prevDay = event.prevValue.replace(",", "").split(" ")[1];
        const newDate = event.newValue.replace(",", "").split(" ");
        const dateValue = newDate;
        const month = monthify(dateValue[0].toLowerCase()).toString().padStart(2, "0");
        const day = dateValue[1].padStart(2, "0");
        const year = Number(dateValue[2]);
        const dateFormat = `${year}-${month}-${day}`;

        date.value = dateFormat;
        if (prevDay !== newDate[1]) {
          datePicker.style.display = "none";
        }
      });
    }, "2000");

    calendar.addEventListener("click", (event) => {
      event.preventDefault();
      datePicker.style.display = "block";

      document.addEventListener("click", function calendarClose(evt) {
        if (!dateColumn.contains(evt.target)) {
          datePicker.style.display = "none";
          document.removeEventListener("click", calendarClose(evt), false);
        }
      }, false);
    });

    close.addEventListener("click", (event) => {
      event.preventDefault();
      datePicker.style.display = "none";
    });
  });
}
