function formDatePicker(){
  $('[data-datepicker]').each(
    function(){
      var customStartDate = $(this).attr('data-startdate') || '',
      selectedLang = $("html").attr('lang') || 'en';
      $(this).fdatepicker({
    		initialDate: customStartDate,
        language: selectedLang,
    		disableDblClickSelection: true,
    		leftArrow:'<<',
    		rightArrow:'>>'
    	})
      .on('changeDate', function (ev) {
        $(ev.target).siblings("input").val(moment(ev.date));
      });
    }
  );
}


