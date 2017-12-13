$(() => {
  window.DecidimProposalWizard = window.DecidimProposalWizard || {};

  window.DecidimProposalWizard.bindProposalWizardAddress = () => {
    const $checkbox = $('#proposal_wizard_has_address');
    const $addressInput = $('#address_input');

    if ($checkbox.length > 0) {
      const toggleInput = () => {
        if ($checkbox[0].checked) {
          $addressInput.show();
        } else {
          $addressInput.hide();
        }
      }
      toggleInput();
      $checkbox.on('change', toggleInput);
    }

    new window.Decidim.Select2Field($('#proposal_wizard_scope_id')); // eslint-disable-line no-new
  };

  window.DecidimProposalWizard.bindProposalWizardAddress();
});
