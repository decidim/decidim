$(() => {
  const $form = $(".form.newsletter_deliver");

  if ($form.length > 0) {
    const $sendNewsletterToAllUsers = $form.find("#send_newsletter_to_all_users");
    const $sendNewsletterToFollowers = $form.find("#send_newsletter_to_followers");
    const $sendNewsletterToParticipants = $form.find("#send_newsletter_to_participants");
    const $sendNewsletterToPrivateMembers = $form.find("#send_newsletter_to_private_members");
    const $participatorySpacesForSelect = $form.find("#participatory_spaces_for_select");

    const checkSelectiveNewsletterFollowers = $sendNewsletterToFollowers.find("input[type='checkbox']").prop("checked");
    const checkSelectiveNewsletterParticipants = $sendNewsletterToParticipants.find("input[type='checkbox']").prop("checked");
    const checkSelectiveNewsletterPrivateMembers = $sendNewsletterToPrivateMembers.find("input[type='checkbox']").prop("checked");

    const $deliverButton = $form.find("#deliver-button");
    const $confirmRecipientsLink = $form.find("#confirm-recipients-link");

    const updateButtonAndLink = () => {
      const sendToFollowersChecked = $sendNewsletterToFollowers.find("input[type='checkbox']").prop("checked");
      const sendToParticipantsChecked = $sendNewsletterToParticipants.find("input[type='checkbox']").prop("checked");
      const sendToPrivateMembersChecked = $sendNewsletterToPrivateMembers.find("input[type='checkbox']").prop("checked");
      const anyOtherChecked = sendToFollowersChecked || sendToParticipantsChecked || sendToPrivateMembersChecked;

      if (anyOtherChecked) {
        $deliverButton.addClass("hidden");
        $confirmRecipientsLink.removeClass("hidden");
      } else {
        $deliverButton.removeClass("hidden");
        $confirmRecipientsLink.addClass("hidden");
      }
    };

    $sendNewsletterToAllUsers.on("change", (event) => {
      const checked = event.target.checked;
      if (checked) {
        $sendNewsletterToFollowers.find("input[type='checkbox']").prop("checked", !checked);
        $sendNewsletterToParticipants.find("input[type='checkbox']").prop("checked", !checked);
        $sendNewsletterToPrivateMembers.find("input[type='checkbox']").prop("checked", !checked);
        $participatorySpacesForSelect.hide();
      } else {
        $sendNewsletterToFollowers.find("input[type='checkbox']").prop("checked", !checked);
        $sendNewsletterToParticipants.find("input[type='checkbox']").prop("checked", !checked);
        $sendNewsletterToPrivateMembers.find("input[type='checkbox']").prop("checked", !checked);
        $participatorySpacesForSelect.show();
      }

      updateButtonAndLink();
    })

    $sendNewsletterToFollowers.on("change", (event) => {
      const checked = event.target.checked;
      const selectiveNewsletterParticipants = $sendNewsletterToParticipants.find("input[type='checkbox']").prop("checked");
      const selectiveNewsletterPrivateMembers = $sendNewsletterToPrivateMembers.find("input[type='checkbox']").prop("checked");

      if (checked) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", false);
        $participatorySpacesForSelect.show();
      } else if (!selectiveNewsletterParticipants && !selectiveNewsletterPrivateMembers) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", true);
        $participatorySpacesForSelect.hide();
      }

      updateButtonAndLink();
    });

    $sendNewsletterToParticipants.on("change", (event) => {
      const checked = event.target.checked;
      const selectiveNewsletterFollowers = $sendNewsletterToFollowers.find("input[type='checkbox']").prop("checked");
      const selectiveNewsletterPrivateMembers = $sendNewsletterToPrivateMembers.find("input[type='checkbox']").prop("checked");

      if (checked) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", false);
        $participatorySpacesForSelect.show();
      } else if (!selectiveNewsletterFollowers && !selectiveNewsletterPrivateMembers) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", true);
        $participatorySpacesForSelect.hide();
      }

      updateButtonAndLink();
    });

    $sendNewsletterToPrivateMembers.on("change", (event) => {
      const checked = event.target.checked;
      const selectiveNewsletterFollowers = $sendNewsletterToFollowers.find("input[type='checkbox']").prop("checked");
      const selectiveNewsletterParticipants = $sendNewsletterToParticipants.find("input[type='checkbox']").prop("checked");

      if (checked) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", false);
        $participatorySpacesForSelect.show();
      } else if (!selectiveNewsletterFollowers && !selectiveNewsletterParticipants) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", true);
        $participatorySpacesForSelect.hide();
      }

      updateButtonAndLink();
    });

    if (checkSelectiveNewsletterFollowers || checkSelectiveNewsletterParticipants || checkSelectiveNewsletterPrivateMembers) {
      $participatorySpacesForSelect.show();
    } else {
      $participatorySpacesForSelect.hide();
    }

    $(".form .spaces-block-tag").each(function (_i, blockTag) {
      const selectTag = $(blockTag).find(".chosen-select");
      selectTag.change(function () {
        let optionSelected = selectTag.find("option:selected").val();
        if (optionSelected === "all") {
          selectTag.find("option").not(":first").prop("selected", true);
          selectTag.find("option[value='all']").prop("selected", false);
        } else if (optionSelected === "") {
          selectTag.find("option").not(":first").prop("selected", false);
        }
      });
    })

    $form.on("change", function(event) {
      let formData = new FormData(event.target.closest("form"));
      let url = $form.data("recipients-count-newsletter-path");
      const $modal = $("#recipients_count_spinner");
      $modal.removeClass("hide");

      const xhr = new XMLHttpRequest();
      xhr.open("POST", url, true);
      xhr.onload = function() {
        if (xhr.status === 200) {
          $("#recipients_count").text(xhr.responseText);
        }
        $modal.addClass("hide");
      };
      xhr.onerror = function() {
        $modal.addClass("hide");
      };
      // Send the form data
      xhr.send(formData);
    })
  }
});
