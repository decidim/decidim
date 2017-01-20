$(document).on('turbolinks:load', () => {
  const $userRegistrationForm = $('.register-form');
  const $userGroupFields = $userRegistrationForm.find('.user-group-fields');

  $userGroupFields.hide();
  
  $userRegistrationForm.on('change', 'input[name="user[sign_up_as]"]', (event) => {
    const value = event.target.value;

    if (value === 'user') {
      $userGroupFields.hide();
    } else {
      $userGroupFields.show();
    }
  });
});
