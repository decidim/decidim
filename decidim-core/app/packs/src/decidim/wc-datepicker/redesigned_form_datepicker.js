/* eslint-disable require-jsdoc */
import { WcDatepicker } from "wc-datepicker/dist/components/wc-datepicker";
import generateDatePicker from "./redesigned_generate_datepicker";
import generateTimePicker from "./redesigned_generate_timepicker";

export default function redesignedFormDatePicker() {
  customElements.define("wc-datepicker", WcDatepicker);
  const format = 12;
  const inputs = document.querySelectorAll('input[type="datetime-local"], input[type="datetime"], input[type="date"]');

  inputs.forEach((input) => {
    input.style.display = "none";
    const label = input.closest("label");

    const row = document.createElement("div");
    row.setAttribute("class", "datepicker_row");

    generateDatePicker(input, row, format);
    generateTimePicker(input, row, format);

    if (label) {
      label.after(row);
    } else {
      input.after(row);
    }

    if (format === 12) {
      document.querySelectorAll(".period_am").forEach((radio) => radio.checked = true);
    };

  });
};
