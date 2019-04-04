$(() => {
  const $form = $(".form.newsletter_deliver");

  if ($form.length > 0) {
    const $sendNewsletterToAllUsers = $form.find("#send_newsletter_to_all_users");
    const $sendNewsletterToFollowers = $form.find("#send_newsletter_to_followers");
    const $sendNewsletterToParticipants = $form.find("#send_newsletter_to_participants");
    const $participatorySpacesForSelect = $form.find("#participatory_spaces_for_select");

    const checkSelectiveNewsletterFollowers = $sendNewsletterToFollowers.find("input[type='checkbox']").prop("checked");
    const checkSelectiveNewsletterParticipants = $sendNewsletterToParticipants.find("input[type='checkbox']").prop("checked");

    $sendNewsletterToAllUsers.on("change", (event) => {
      const checked = event.target.checked;
      if (checked) {
        $sendNewsletterToFollowers.find("input[type='checkbox']").prop("checked", !checked);
        $sendNewsletterToParticipants.find("input[type='checkbox']").prop("checked", !checked);
        $participatorySpacesForSelect.hide();
      } else {
        $sendNewsletterToFollowers.find("input[type='checkbox']").prop("checked", !checked);
        $sendNewsletterToParticipants.find("input[type='checkbox']").prop("checked", !checked);
        $participatorySpacesForSelect.show();
      }
    })

    $sendNewsletterToFollowers.on("change", (event) => {
      const checked = event.target.checked;
      const selectiveNewsletterParticipants = $sendNewsletterToParticipants.find("input[type='checkbox']").prop("checked");

      if (checked) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", !checked);
        $participatorySpacesForSelect.show();
      } else if (!selectiveNewsletterParticipants) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", true);
        $participatorySpacesForSelect.hide();
      }
    })

    $sendNewsletterToParticipants.on("change", (event) => {
      const checked = event.target.checked;
      const selectiveNewsletterFollowers = $sendNewsletterToFollowers.find("input[type='checkbox']").prop("checked");
      if (checked) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", !checked);
        $participatorySpacesForSelect.show();
      } else if (!selectiveNewsletterFollowers) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", true);
        $participatorySpacesForSelect.hide();
      }
    })

    if (checkSelectiveNewsletterFollowers || checkSelectiveNewsletterParticipants) {
      $participatorySpacesForSelect.show();
    } else {
      $participatorySpacesForSelect.hide();
    }
  }
})(window);
