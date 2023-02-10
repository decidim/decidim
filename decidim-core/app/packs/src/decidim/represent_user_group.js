/**
 * @deprecated since feature/redesign
 */
$(() => {
  const $checkbox = $("#user_group");

  $checkbox.click(() => {
    const $select = $checkbox.siblings("select");

    if (!$select.val()) {
      $select.toggle();
    }

    if ($select.is(":visible")) {
      $checkbox.prop("checked", true);
    } else {
      $checkbox.prop("checked", false);
    }
  });
});
