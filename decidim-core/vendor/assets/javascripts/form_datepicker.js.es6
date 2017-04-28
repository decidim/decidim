((exports) => {
  const formDatePicker = () => {
    $('[data-datepicker]').each((_index, node) => {
      const language = $('html').attr('lang') || 'en';
      const initialDate = $(node).data('startdate') || '';
      const pickTime = $(node).data('timepicker') === '';
      const languageProps = $(node).fdatepicker.dates[language] && $(node).fdatepicker.dates[language].format;
      let format = languageProps || 'mm/dd/yyyy';

      if (pickTime) {
        format = `${format}, hh:ii`;
      }

      $(node).fdatepicker({
        format,
        initialDate,
        language,
        pickTime,
        disableDblClickSelection: true,
        leftArrow: '<<',
        rightArrow: '>>'
      }).on('changeDate', (ev) => {
        let newDate = exports.moment.utc(ev.date).format('YYYY-MM-DDTHH:mm:ss');

        $(ev.target).siblings('input').val(newDate);
      });
    });
  };

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.formDatePicker = formDatePicker;
})(window);
