$(() => {
  window.DecidimProposals = window.DecidimProposals || {};

  window.DecidimProposals.foo = () => {
    const $checkbox = $('#toggle_address');
    const $addressInput = $('#address_input');

    const toggleInput = () => {
      if ($checkbox[0].checked) {
        $addressInput.show();
      } else {
        $addressInput.hide();
      }
    }

    toggleInput();

    $checkbox.on('change', () => {
      toggleInput();
    });
  };

  window.DecidimProposals.foo();
});

