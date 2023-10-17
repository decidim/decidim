/* eslint-disable require-jsdoc */
import { WcDatepicker } from "wc-datepicker/dist/components/wc-datepicker";
import generateDatePicker from "./generate_datepicker";
import generateTimePicker from "./generate_timepicker";
import { formatInputDate, formatInputTime } from "./datepicker_functions";
import { getDictionary } from "../i18n";

export default function redesignedFormDatePicker() {
  const i18n = getDictionary("date.formats");
  const i18nHelp = getDictionary("date.formats.help");
  const i10n = getDictionary("time");
  const i10nHelp = getDictionary("time.formats.help");

  const formats = { date: i18n.decidim_short, time: i10n.clock_format || 24 }

  if (!customElements.get("wc-datepicker")) {
    customElements.define("wc-datepicker", WcDatepicker);
  };

  const inputs = document.querySelectorAll('input[type="datetime-local"], input[type="date"]');

  inputs.forEach((input) => {
    input.style.display = "none";
    const label = input.closest("label");

    const row = document.createElement("div");
    row.setAttribute("id", `${input.id}_datepicker_row`);
    row.setAttribute("class", "datepicker_row");

    const helpTextContainer = document.createElement("div");
    helpTextContainer.setAttribute("class", "help_text_container");

    const helpTextDate = document.createElement("span");
    helpTextDate.setAttribute("class", "help-text help_date");
    helpTextDate.innerText = i18nHelp.date_format;

    const helpTextTime = document.createElement("span");
    helpTextTime.setAttribute("class", "help-text help_time");
    helpTextTime.innerText = i10nHelp.time_format;

    helpTextContainer.appendChild(helpTextDate);

    if (label) {
      label.after(row);
    } else {
      input.after(row);
    };

    generateDatePicker(input, row, formats);

    if (input.type === "datetime-local") {
      generateTimePicker(input, row, formats);
      helpTextContainer.appendChild(helpTextTime);
    };

    row.before(helpTextContainer);

    if (formats.time === 12) {
      document.getElementById(`period_am_${input.id}`).checked = true;
    };

    const inputFieldValue = document.getElementById(`${input.id}`).value;

    if (inputFieldValue !== "") {
      if (input.type === "datetime-local") {
        const dateTimeValue = inputFieldValue.split("T");
        const date = dateTimeValue[0];
        const time = dateTimeValue[1];

        document.getElementById(`${input.id}_date`).value = formatInputDate(date, formats.date, input);
        document.getElementById(`${input.id}_time`).value = formatInputTime(time, formats.time, input);
      } else if (input.type === "date") {
        document.getElementById(`${input.id}_date`).value = formatInputDate(inputFieldValue, formats.date, input);
      };
    };
  });

  if (inputs.length > 0) {
    inputs.forEach((input) => {
      if (input.classList.contains("is-invalid-input")) {
        document.getElementById(`${input.id}_date`).classList.add("is-invalid-input");
        document.getElementById(`${input.id}_time`).classList.add("is-invalid-input");
        input.parentElement.querySelectorAll(".form-error").forEach((error) => {
          document.getElementById(`${input.id}_datepicker_row`).before(error);
        });
      };
    });
  };
};
