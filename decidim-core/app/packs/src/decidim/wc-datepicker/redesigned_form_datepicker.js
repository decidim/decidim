/* eslint-disable require-jsdoc */
import { WcDatepicker } from "wc-datepicker/dist/components/wc-datepicker";
import generateDatePicker from "./redesigned_generate_datepicker";
import generateTimePicker from "./redesigned_generate_timepicker";
import { formatInputDate, formatInputTime } from "./redesigned_datepicker_functions";

export default function redesignedFormDatePicker() {
  customElements.define("wc-datepicker", WcDatepicker);
  const format = 12;
  const inputs = document.querySelectorAll('input[type="datetime-local"], input[type="datetime"], input[type="date"]');

  inputs.forEach((input) => {
    input.style.display = "none";
    const label = input.closest("label");

    const row = document.createElement("div");
    row.setAttribute("id", `${input.id}_datepicker_row`)
    row.setAttribute("class", "datepicker_row");

    generateDatePicker(input, row, format);
    generateTimePicker(input, row, format);

    if (label) {
      label.after(row);
    } else {
      input.after(row);
    };

    if (format === 12) {
      document.getElementById(`period_am_${input.id}`).checked = true;
    };

    const inputFieldValue = document.getElementById(`${input.id}`).value;

    if (inputFieldValue !== "") {
      const dateTimeValue = inputFieldValue.split("T");
      const date = dateTimeValue[0];
      const time = dateTimeValue[1];

      document.getElementById(`${input.id}_date`).value = formatInputDate(date, format, input);
      document.getElementById(`${input.id}_time`).value = formatInputTime(time, format, input);
    };
  });

  document.querySelector("button[name=\"commit\"]").addEventListener("click", () => {
    inputs.forEach((input) => {
      if (input.classList.contains("is-invalid-input")) {
        document.getElementById(`${input.id}_date`).classList.add("is-invalid-input");
        document.getElementById(`${input.id}_time`).classList.add("is-invalid-input");
        document.getElementById(`${input.id}_datepicker_row`).after(document.getElementById(input.getAttribute("aria-describedby")));
        document.getElementById(`${input.id}_date`).setAttribute("aria-describedby", input.getAttribute("aria-describedby"));
        document.getElementById(`${input.id}_time`).setAttribute("aria-describedby", input.getAttribute("aria-describedby"));
      };
    });
  });
};
