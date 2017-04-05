function formDatePicker(){
  $('[data-datepicker]').each(
    function(){
      const initialDate = $(this).attr('data-startdate') || '';
      const language = $("html").attr('lang') || 'en';
      const pickTime = $(this).attr('data-timepicker') === '';
      const format = $(this).fdatepicker.dates[language] && $(this).fdatepicker.dates[language].format || 'mm/dd/yyyy';

      if (pickTime) {
         format = `${format}, hh:ii`;
      };

      $(this).fdatepicker({
        format,
    		initialDate,
        language,
    		disableDblClickSelection: true,
    		leftArrow:'<<',
    		rightArrow:'>>',
        pickTime
    	})
      .on('changeDate', function (ev) {
        $(ev.target).siblings("input").val(moment.utc(ev.date));
      });
    }
  );
}


