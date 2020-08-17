$(() => {
  const { attachGeocoding } = window.Decidim;

  const $form = $(".proposal_form_admin");

  if ($form.length > 0) {
    const $proposalCreatedInMeeting = $form.find("#proposal_created_in_meeting");
    const $proposalMeeting = $form.find("#proposal_meeting");

    const toggleDisabledHiddenFields = () => {
      const enabledMeeting = $proposalCreatedInMeeting.prop("checked");
      $proposalMeeting.find("select").attr("disabled", "disabled");
      $proposalMeeting.hide();

      if (enabledMeeting) {
        $proposalMeeting.find("select").attr("disabled", !enabledMeeting);
        $proposalMeeting.show();
      }
    };

    $proposalCreatedInMeeting.on("change", toggleDisabledHiddenFields);
    toggleDisabledHiddenFields();

    attachGeocoding($form.find("#proposal_address"));
  }
});
