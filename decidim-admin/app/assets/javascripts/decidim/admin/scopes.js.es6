function formatScope(scope) {
  if (scope.deprecated)
    return $('<span class="deprecated">' + scope.text + '</span>');
  else
    return scope.text;
};

$(() => {
  $(".scope_freetext").select2({
    ajax: {
      url: "/admin/scopes/search.json",
      cache: true
    },
    allowClear: true,
    templateSelection: formatScope,
    templateResult: formatScope
  })
})

