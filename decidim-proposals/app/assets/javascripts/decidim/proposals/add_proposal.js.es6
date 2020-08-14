$(() => {
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
      $("input", $addressInput).on("geocoder-suggest-coordinates.decidim", (_ev, coordinates) => {
        let $latitude = $("#proposal_latitude");
        let $longitude = $("#proposal_longitude");
        if ($latitude.length < 1) {
          $latitude = $('<input type="hidden" name="proposal[latitude]" id="proposal_latitude" />');
          $addressInput.append($latitude);
        }
        if ($longitude.length < 1) {
          $longitude = $('<input type="hidden" name="proposal[longitude]" id="proposal_longitude" />');
          $addressInput.append($longitude);
        }

        $latitude.val(coordinates[0]).attr("value", coordinates[0]);
        $longitude.val(coordinates[1]).attr("value", coordinates[1]);
      });
    }
  };

  window.DecidimProposals.bindProposalAddress();
});
