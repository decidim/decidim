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
    $scopes.attr('checked', false);
    $sort.attr('checked', false)

    let [sortValue] = getLocationParams(/order_start_time=([^&]*)/g) || ["asc"];
    $form.find(`input[type=radio][value=${sortValue}]`)[0].checked = true;

    let scopeValues = getLocationParams(/scope_id\[\]=([^&]*)/g) || [];
    console.log(scopeValues)
    scopeValues.forEach(value => {
      $form.find(`input[type=checkbox][value=${value}]`)[0].checked = true;
    })

    let [categoryIdValue] = getLocationParams(/filter\[category_id\]=([^&]*)/g) || [];
    $form.find(`select#filter_category_id`).first().val(categoryIdValue);

    $form.submit();
  };

  const getLocationParams = (regex) => {
    const location = decodeURIComponent(document.location);
    let values = location.match(regex);
    if (values) {
      values = values.map(val => val.match(/=(.*)/)[1]);
    }
    return values;
  };
});
