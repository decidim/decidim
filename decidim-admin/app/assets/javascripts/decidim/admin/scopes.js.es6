$(() => {
  const selectedLang = $("html").attr('lang') || 'en';
  $(".select2").select2({
    ajax: {
      url: "/scopes/search.json",
      language: selectedLang,
      cache: true
    },
    allowClear: true
  })
})
