import DatePickerController from "src/decidim/controllers/date_picker/controller";

document.addEventListener("stimulus:load", () => {
  window.Stimulus.register("date-picker", DatePickerController);
}, { once: true });
