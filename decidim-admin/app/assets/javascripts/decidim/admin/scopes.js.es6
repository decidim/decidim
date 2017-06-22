$(() => {
  var selectedLang = $("html").attr('lang') || 'ca';
  $(".scope_freetext").select2({
    ajax: {
      url: "/admin/scopes/search.json",
      language: selectedLang,
      cache: true
    },
    allowClear: true
  })
})