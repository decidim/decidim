// = require_self
$(document).ready(() => {
  const $form = $('form#new_filter');
  const $scopes = $form.find('input[type=checkbox]');
  const $sort = $form.find('input[type=radio]');
  $form.on('change', 'input, select', (event) => {
    $form.submit();

    let newUrl;
    const formAction = $form.attr('action');
    const params = $form.serialize();

    if (formAction.indexOf('?') < 0) {
      newUrl = `${formAction}?${params}`;
    } else {
      newUrl = `${formAction}&${params}`;
    }

    window.history.pushState(null, null, newUrl);
  });

  window.onpopstate = function(event) {
    const location = decodeURIComponent(document.location);

    $scopes.attr('checked', false);
    $sort.attr('checked', false)

    try {
      const [, sortValue] = location.match(/order_start_time=([^&]*)/);
      $form.find(`input[type=radio][value=${sortValue}]`)[0].checked = true;
    } catch(e) {
      $form.find('input[type=radio][value=asc]')[0].checked = true;
    }

    let scopeValues = location.match(/scope_id\[\]=([^&]*)/g);
    if (scopeValues) {
      scopeValues = scopeValues.map(val => val.match(/scope_id\[\]=(.*)/)[1]);
      scopeValues.forEach(value => {
        $form.find(`input[type=checkbox][value=${value}]`)[0].checked = true;
      })
    }

    let categoryIdValues = location.match(/filter\[category_id\]=([^&]*)/g);
    if (categoryIdValues) {
      categoryIdValues = categoryIdValues[0].match(/=(.*)/)[1];
      $form.find(`select#filter_category_id`).first().val(categoryIdValues);
    }

    $form.submit();
  };
});
