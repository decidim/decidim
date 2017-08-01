$(() => {
  const selectedLang = $("html").attr('lang') || 'en';
  $(".select2").each(function(index, select) {
    let $element = $(select);
    let options = {
      language: selectedLang,
      multiple: $element.attr("multiple")==="multiple",
      width: "100%",
      allowClear: true
    };
    if ($element.data("remote-path")) {
      options.ajax = {
        url: $element.data("remote-path"),
        delay: 250,
        cache: true
      };
    }
    $element.select2(options);
  });
});
