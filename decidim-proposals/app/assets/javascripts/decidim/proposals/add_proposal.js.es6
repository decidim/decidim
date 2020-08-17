$(() => {
  const { attachGeocoding } = window.Decidim;

  window.DecidimProposals = window.DecidimProposals || {};

  window.DecidimProposals.bindProposalAddress = () => {
    const $checkbox = $("input:checkbox[name$='[has_address]']");
    const $addressInput = $("#address_input");

    if ($checkbox.length > 0) {
      const toggleInput = () => {
        if ($checkbox[0].checked) {
          $addressInput.show();
        } else {
          $addressInput.hide();
        }
      }
      toggleInput();
      $checkbox.on("change", toggleInput);
    }

    if ($addressInput.length > 0) {
      attachGeocoding($("input", $addressInput));
    }
  };

  window.DecidimProposals.bindProposalAddress();
});
