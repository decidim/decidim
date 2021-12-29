$(() => {
  const $checkbox = $(".represent-user-group").find("input#user_group");
  const $userGroupFields = $(".user-group-fields");

  $checkbox.click(() => {
    const $select = $userGroupFields.find("select");

    if (!$select.val()) {
      $userGroupFields.toggle();
    }

    if ($userGroupFields.is(":visible")) {
      $checkbox.prop("checked", true);
    } else {
      $checkbox.prop("checked", false);
    }
  });
});
