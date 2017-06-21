$(() => {
  $(".scope_freetext").select2({
    ajax: {
      url: "/admin/scopes/search.json",
      cache: true
    },
    allowClear: true
  })
})

