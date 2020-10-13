(() => {
  const $scope = $("#promoting-committee-details");

  const $promotingCommitteeCheckbox = $(
    "#initiatives_type_promoting_committee_enabled",
    $scope
  );

  const $signatureType = $("#initiatives_type_signature_type");

  const $collectUserDataCheckbox = $("#initiatives_type_collect_user_extra_fields");

  const toggleVisibility = () => {
    if ($promotingCommitteeCheckbox.is(":checked")) {
      $(".minimum-committee-members-details", $scope).show();
    } else {
      $(".minimum-committee-members-details", $scope).hide();
    }

    if ($signatureType.val() === "offline") {
      $("#initiatives_type_undo_online_signatures_enabled").parent().parent().hide();
    } else {
      $("#initiatives_type_undo_online_signatures_enabled").parent().parent().show();
    }

    if ($collectUserDataCheckbox.is(":checked")) {
      $("#initiatives_type-extra_fields_legal_information-tabs").parent().parent().show()
    } else {
      $("#initiatives_type-extra_fields_legal_information-tabs").parent().parent().hide()
    }
  };

  $($promotingCommitteeCheckbox).click(() => toggleVisibility());
  $($signatureType).change(() => toggleVisibility());
  $($collectUserDataCheckbox).click(() => toggleVisibility());

  toggleVisibility();
})();
