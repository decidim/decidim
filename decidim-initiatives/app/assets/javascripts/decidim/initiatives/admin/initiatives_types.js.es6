(() => {
  const $scope = $("#promoting-committee-details");

  const $promotingCommitteeCheckbox = $(
    "#initiatives_type_promoting_committee_enabled",
    $scope
  );

  const toggleVisibility = () => {
    if ($promotingCommitteeCheckbox.is(":checked")) {
      $(".minimum-committee-members-details", $scope).show();
    } else {
      $(".minimum-committee-members-details", $scope).hide();
    }
  };

  $($promotingCommitteeCheckbox).click(() => toggleVisibility());

  toggleVisibility();
})();
