/* eslint-disable require-jsdoc */
import { WcDatepicker } from "wc-datepicker/dist/components/wc-datepicker";

customElements.define("wc-datepicker", WcDatepicker);

const inputs = document.querySelectorAll('input[type="datetime-local"], input[type="datetime"], input[type="date"]');

inputs.forEach((input) => {
  input.style.display = "none";
  const label = input.closest("label");

  const date = document.createElement("input");
  date.setAttribute("id", `${input.id}_date`);
  date.setAttribute("class", "datepicker");
  date.setAttribute("type", "date");

  const time = document.createElement("input");
  time.setAttribute("id", `${input.id}_time`);
  time.setAttribute("class", "timepicker");
  time.setAttribute("type", "time");

  const row = document.createElement("div");
  row.setAttribute("class", "timepicker_row");

  const dateColumn = document.createElement("div");
  dateColumn.setAttribute("class", "date_column");

  const timeColumn = document.createElement("div");
  timeColumn.setAttribute("class", "time_column");

  dateColumn.appendChild(date);
  timeColumn.appendChild(time);
  row.append(dateColumn, timeColumn);

  const datePicker = document.createElement("wc-datepicker");
  datePicker.setAttribute("id", `${date.id}_datepicker`);
  datePicker.style.display = "none";

  if (label) {
    label.after(row);
    date.after(datePicker);
  } else {
    input.after(row);
    date.after(datePicker);
  }

  [date, time].forEach((picker) => {
    picker.addEventListener("click", (event) => {
      event.preventDefault();
      if (picker === date) {
        datePicker.style.display = "block";
      }
    });
  });

  document.addEventListener("click", (event) => {
    if (!datePicker.style.display === "none" && !datePicker.contains(event.target)) {
      datePicker.style.display = "none";
    }
  });
});

export default function formDatePicker() {
  $('[type="datetime-local"]').each((_index, node) => {

    node.addEventListener("click", function() {

    });
  });
}
