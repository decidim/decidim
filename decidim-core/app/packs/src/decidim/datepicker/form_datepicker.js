/* eslint-disable require-jsdoc */
import { defineCustomElements } from "wc-datepicker/dist/loader";
import generateDatePicker from "src/decidim/datepicker/generate_datepicker";
import generateTimePicker from "src/decidim/datepicker/generate_timepicker";
import { formatInputDate, formatInputTime } from "src/decidim/datepicker/datepicker_functions";
import { getDictionary } from "src/decidim/i18n";

export default function formDatePicker(input) {

  const i18nDate = getDictionary("date.formats");
  const i18nDateHelp = getDictionary("date.formats.help");
  const i18nTime = getDictionary("time");
  const i18nTimeHelp = getDictionary("time.formats.help");
  const formats = { order: i18nDate.order, separator: i18nDate.separator, time: i18nTime.clock_format || 24 }

  if (!customElements.get("wc-datepicker")) {
    defineCustomElements();
  };

  if (!input.id) {
    input.id = "demo-datepicker"
  };

  input.style.display = "none";
  const label = input.closest("label");

  const row = document.createElement("div");
  row.setAttribute("id", `${input.id}_datepicker_row`);
  row.setAttribute("class", "datepicker__datepicker-row");

  const helpTextContainer = document.createElement("div");
  helpTextContainer.setAttribute("class", "datepicker__help-text-container");

  const helpTextDate = document.createElement("span");
  helpTextDate.setAttribute("class", "help-text datepicker__help-date");
  helpTextDate.innerText = i18nDateHelp.date_format;

  const helpTextTime = document.createElement("span");
  helpTextTime.setAttribute("class", "help-text datepicker__help-time");
  helpTextTime.innerText = i18nTimeHelp.time_format;

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

  if (!input.getAttribute("hide_help")) {
    label.appendChild(helpTextContainer);
  };

  if (formats.time === 12) {
    document.getElementById(`period_am_${input.id}`).checked = true;
  };

  const inputFieldValue = document.getElementById(`${input.id}`).value;

  if (inputFieldValue !== "") {
    if (input.type === "datetime-local") {
      const dateTimeValue = inputFieldValue.split("T");
      const date = dateTimeValue[0];
      const time = dateTimeValue[1];

      document.getElementById(`${input.id}_date`).value = formatInputDate(date, formats, input);
      document.getElementById(`${input.id}_time`).value = formatInputTime(time, formats.time, input);
    } else if (input.type === "date") {
      document.getElementById(`${input.id}_date`).value = formatInputDate(inputFieldValue, formats, input);
    };
  };

  if (document.querySelector('button[name="commit"]')) {
    document.querySelector('button[name="commit"]').addEventListener("click", () => {
      if (input.classList.contains("is-invalid-input")) {
        document.getElementById(`${input.id}_date`).classList.add("is-invalid-input");
        document.getElementById(`${input.id}_time`).classList.add("is-invalid-input");
        input.parentElement.querySelectorAll(".form-error").forEach((error) => {
          document.getElementById(`${input.id}_datepicker_row`).after(error);
        });
      };
    });
  };
};
