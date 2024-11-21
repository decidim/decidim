$(() => {
  const $form = $(".form.newsletter_deliver");

  if ($form.length > 0) {
    const $sendNewsletterToAllUsers = $form.find("#send_newsletter_to_all_users");
    const $sendNewsletterToVerifiedUsers = $form.find("#send_newsletter_to_verified_users");
    const $sendNewsletterToFollowers = $form.find("#send_newsletter_to_followers");
    const $sendNewsletterToParticipants = $form.find("#send_newsletter_to_participants");
    const $sendNewsletterToPrivateMembers = $form.find("#send_newsletter_to_private_members");
    const $participatorySpacesForSelect = $form.find("#participatory_spaces_for_select");
    const $verificationTypesForSelect = $form.find("#verification_types_for_select");

    const $deliverButton = $form.find("#deliver-button");
    const $confirmRecipientsLink = $form.find("#confirm-recipients-link");

    // Update hidden field for the checkbox
    const updateHiddenField = ($checkbox) => {
      const hiddenInput = $checkbox.siblings(`input[name="${$checkbox.attr("name")}"][type="hidden"]`);
      hiddenInput.val($checkbox.prop("checked")
        ? "1"
        : "0");
    };

    // Reset selective checkboxes (Followers, Participants, Private Members)
    const resetSelectiveCheckboxes = () => {
      [$sendNewsletterToFollowers, $sendNewsletterToParticipants, $sendNewsletterToPrivateMembers].forEach(
        ($checkbox) => {
          $checkbox.find("input[type='checkbox']").prop("checked", false);
          updateHiddenField($checkbox.find("input[type='checkbox']"));
        }
      );
    };

    // Reset "All Users" and "Verified Users" checkboxes if selective checkboxes are selected
    const resetExclusiveCheckboxes = (except) => {
      [$sendNewsletterToAllUsers, $sendNewsletterToVerifiedUsers].
        filter(($checkbox) => $checkbox !== except).
        forEach(($checkbox) => {
          $checkbox.find("input[type='checkbox']").prop("checked", false);
          updateHiddenField($checkbox.find("input[type='checkbox']"));
        });
    };

    // Update the confirm recipients link
    const updateConfirmRecipientsLink = () => {
      const params = new URLSearchParams();

      $form.serializeArray().forEach(({ name, value }) => {
        params.append(name, value);
      });

      const baseUrl = $confirmRecipientsLink.data("base-url");
      if (baseUrl) {
        const fullUrl = `${baseUrl}?${params.toString()}`;
        $confirmRecipientsLink.attr("href", fullUrl);
      } else {
        console.error("Base URL for confirm recipients link is missing.");
      }
    };

    // Update the visibility of the submit button and confirm link
    const updateButtonAndLink = () => {
      const isAnyChecked = [
        $sendNewsletterToAllUsers,
        $sendNewsletterToVerifiedUsers,
        $sendNewsletterToFollowers,
        $sendNewsletterToParticipants,
        $sendNewsletterToPrivateMembers,
      ].some(($checkbox) => $checkbox.find("input[type='checkbox']").prop("checked"));

      if (isAnyChecked) {
        $deliverButton.addClass("hidden");
        $confirmRecipientsLink.removeClass("hidden");
      } else {
        $deliverButton.removeClass("hidden");
        $confirmRecipientsLink.addClass("hidden");
      }

      updateConfirmRecipientsLink();
    };

    // Update the visibility of the participatory spaces block
    const updateSpacesVisibility = () => {
      const isAnySelectiveChecked = [
        $sendNewsletterToFollowers,
        $sendNewsletterToParticipants,
        $sendNewsletterToPrivateMembers,
      ].some(($checkbox) => $checkbox.find("input[type='checkbox']").prop("checked"));

      $participatorySpacesForSelect.toggle(isAnySelectiveChecked);
    };

    // Update the visibility of the verification types block
    const updateVerificationTypesVisibility = () => {
      const isVerifiedChecked = $sendNewsletterToVerifiedUsers.find("input[type='checkbox']").prop("checked");
      $verificationTypesForSelect.toggle(isVerifiedChecked);
    };

    // Update hidden fields and trigger button/link update
    const updateAll = ($checkbox) => {
      const hiddenInput = $checkbox.find("input[type='hidden']");
      hiddenInput.val(
        $checkbox.find("input[type='checkbox']").prop("checked")
          ? "1"
          : "0"
      );
      updateButtonAndLink();
    };

    const initVisibility = () => {
      updateSpacesVisibility();
      updateVerificationTypesVisibility();
    };

    // Event listeners for checkboxes
    $sendNewsletterToAllUsers.on("change", (event) => {
      const checked = event.target.checked;

      if (checked) {
        resetExclusiveCheckboxes($sendNewsletterToAllUsers);
        resetSelectiveCheckboxes();
      }

      initVisibility();
      updateAll($sendNewsletterToAllUsers);
    });

    $sendNewsletterToVerifiedUsers.on("change", (event) => {
      const checked = event.target.checked;

      if (checked) {
        resetExclusiveCheckboxes($sendNewsletterToVerifiedUsers);
        resetSelectiveCheckboxes();
      }
      updateVerificationTypesVisibility();
      updateAll($sendNewsletterToVerifiedUsers);
    });

    // Allow simultaneous selection for Followers, Participants, and Private Members
    [$sendNewsletterToFollowers, $sendNewsletterToParticipants, $sendNewsletterToPrivateMembers].forEach(
      ($checkbox) => {
        $checkbox.on("change", () => {
          // Reset "All Users" and "Verified Users" if selective checkboxes are selected
          if ($checkbox.find("input[type='checkbox']").prop("checked")) {
            resetExclusiveCheckboxes();
          }

          initVisibility();
          updateAll($checkbox);
        });
      }
    );

    // Initialize visibility
    initVisibility();

    // Event listener for changes in participatory spaces select
    $(".form .spaces-block-tag").each((_i, blockTag) => {
      const selectTag = $(blockTag).find(".chosen-select");
      selectTag.change(() => {
        const optionSelected = selectTag.find("option:selected").val();
        if (optionSelected === "all") {
          selectTag.find("option").not(":first").prop("selected", true);
          selectTag.find("option[value='all']").prop("selected", false);
        } else if (optionSelected === "") {
          selectTag.find("option").not(":first").prop("selected", false);
        }
      });
    });

    // Event listener for updating recipient count
    $form.on("change", (event) => {
      const formData = new FormData(event.target.closest("form"));
      const url = $form.data("recipients-count-newsletter-path");
      const $modal = $("#recipients_count_spinner");
      $modal.removeClass("hide");

      const xhr = new XMLHttpRequest();
      xhr.open("POST", url, true);
      xhr.onload = () => {
        if (xhr.status === 200) {
          $("#recipients_count").text(xhr.responseText);
        }
        $modal.addClass("hide");
      };
      xhr.onerror = () => {
        $modal.addClass("hide");
      };

      // Send the form data
      xhr.send(formData);

      updateConfirmRecipientsLink();
    });
  }
});
