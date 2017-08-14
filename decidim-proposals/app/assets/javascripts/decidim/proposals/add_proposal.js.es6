$(() => {
  window.DecidimProposals = window.DecidimProposals || {};

  window.DecidimProposals.bindProposalAddress = () => {
    const $checkbox = $('#proposal_has_address');
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

    const proposalScope = new window.Decidim.Select2Field($('#proposal_scope_id'));
  };

  window.DecidimProposals.bindProposalAddress();
});

