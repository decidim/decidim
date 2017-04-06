((exports) => {
  const formDatePicker = () => {
    $('[data-datepicker]').each(function () {
      const language = $('html').attr('lang') || 'en';
      const initialDate = $(this).attr('data-startdate') || '';
      const pickTime = $(this).attr('data-timepicker') === '';
      const languageProps = $(this).fdatepicker.dates[language];
      let format = languageProps && languageProps.format || 'mm/dd/yyyy';

      if (pickTime) {
        format = `${format}, hh:ii`;
      };

      $(this).fdatepicker({
        format,
        initialDate,
        language,
        pickTime,
        disableDblClickSelection: true,
        leftArrow: '<<',
        rightArrow: '>>'
      })
      .on('changeDate', (ev) => {
        $(ev.target).siblings('input').val(exports.moment.utc(ev.date));
      });
    });
  };

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.formDatePicker = formDatePicker;
})(window);
