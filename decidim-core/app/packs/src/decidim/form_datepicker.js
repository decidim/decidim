((exports) => {
  const formDatePicker = () => {
    $("[data-datepicker]").each((_index, node) => {
      const language = $("html").attr("lang") || "en";
      const initialDate = $(node).data("startdate") || "";
      const pickTime = $(node).data("timepicker") === "";
      const languageProps = $(node).fdatepicker.dates[language] && $(node).fdatepicker.dates[language].format;
      let format = $(node).data("date-format") || languageProps || "mm/dd/yyyy";

      $(node).fdatepicker({
        format,
        initialDate,
        language,
        pickTime,
        disableDblClickSelection: true,
        leftArrow: "<<",
        rightArrow: ">>"
      });
    });
  };

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.formDatePicker = formDatePicker;
})(window);
