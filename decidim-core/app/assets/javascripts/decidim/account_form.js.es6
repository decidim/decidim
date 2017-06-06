/**
 * Since the delete account has a modal to confirm it we need to copy the content of the
 * reason field to the hidden field in the form inside the modal.
 */
$(() => {
  const $deleteAccountForm = $('.delete-account');
  const $deleteAccountModalForm = $('.delete-account-modal');

  if ($deleteAccountForm.length > 0) {
    const $openModalButton = $('.open-modal-button');
    const $modal = $('#deleteConfirm');

    $openModalButton.on('click', (event) => {
      try {
        const reasonValue = $deleteAccountForm.find('textarea#delete_account_delete_reason').val();
        $deleteAccountModalForm.find('input#delete_account_delete_reason').val(reasonValue);
        $modal.foundation('open');
      } catch (error) {
        console.error(error); // eslint-disable-line no-console
      }

      event.preventDefault();
      event.stopPropagation();
      return false;
    });
  }
});
