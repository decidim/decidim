import TomSelect from "tom-select/dist/cjs/tom-select.popular";

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

    const groupSpecificCheckboxes = [$sendNewsletterToFollowers, $sendNewsletterToParticipants, $sendNewsletterToPrivateMembers];
    const globalCheckboxes = [$sendNewsletterToAllUsers, $sendNewsletterToVerifiedUsers];

    // Update hidden field for the checkbox
    const updateHiddenField = ($checkbox) => {
      const hiddenInput = $checkbox.siblings(`input[name="${$checkbox.attr("name")}"][type="hidden"]`);
      hiddenInput.val($checkbox.prop("checked")
        ? "1"
        : "0");
    };

    const setCheckboxState = ($checkbox, state) => {
      $checkbox.find("input[type='checkbox']").prop("checked", state);
      updateHiddenField($checkbox.find("input[type='checkbox']"));
    };

    // Toggle checkboxes in a group
    const toggleCheckboxGroup = (checkboxes, state) => {
      checkboxes.forEach(($checkbox) => setCheckboxState($checkbox, state));
    };

    // Update the confirm recipients link
    const updateConfirmRecipientsLink = () => {
      const params = new URLSearchParams();

      $form.serializeArray().forEach(({ name, value }) => params.append(name, value));

      const baseUrl = $confirmRecipientsLink.data("base-url");
      if (baseUrl) {
        $confirmRecipientsLink.attr("href", `${baseUrl}?${params.toString()}`);
      } else {
        console.error("Base URL for confirm recipients link is missing.");
      }
    };

    const updateButtonAndLink = () => {
      const isAllUsersChecked = $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked");
      const isAnyChecked = [...globalCheckboxes, ...groupSpecificCheckboxes].some(($checkbox) =>
        $checkbox.find("input[type='checkbox']").prop("checked")
      );

      $deliverButton.toggleClass("hidden", !isAllUsersChecked);
      $confirmRecipientsLink.toggleClass("hidden", isAllUsersChecked || !isAnyChecked);

      updateConfirmRecipientsLink();
    };

    const ensureAtLeastOneCheckboxSelected = () => {
      const isAnyChecked = [...globalCheckboxes, ...groupSpecificCheckboxes].some(($checkbox) =>
        $checkbox.find("input[type='checkbox']").prop("checked")
      );

      if (!isAnyChecked) {
        setCheckboxState($sendNewsletterToAllUsers, true);
      }
    };

    const updateSpacesVisibility = () => {
      const isAnySelectiveChecked = groupSpecificCheckboxes.some(($checkbox) =>
        $checkbox.find("input[type='checkbox']").prop("checked")
      );

      const isVerifiedChecked = $sendNewsletterToVerifiedUsers.find("input[type='checkbox']").prop("checked");

      $participatorySpacesForSelect.toggle(isAnySelectiveChecked && !isVerifiedChecked);
    };

    const updateVerificationTypesVisibility = () => {
      const isVerifiedChecked = $sendNewsletterToVerifiedUsers.find("input[type='checkbox']").prop("checked");
      $verificationTypesForSelect.toggle(isVerifiedChecked);
    };

    const updateVisibility = () => {
      updateSpacesVisibility();
      updateVerificationTypesVisibility();
    };

    const updateAll = ($checkbox) => {
      updateHiddenField($checkbox);
      ensureAtLeastOneCheckboxSelected();
      updateButtonAndLink();
      updateVisibility();
    };

    const selectDefaultCheckboxes = () => {
      toggleCheckboxGroup(groupSpecificCheckboxes, true);
    };

    // Event listeners for checkboxes
    globalCheckboxes.forEach(($checkbox) => {
      $checkbox.on("change", (event) => {
        const checked = event.target.checked;

        if (checked) {
          toggleCheckboxGroup(globalCheckboxes.filter((el) => el !== $checkbox), false);
          toggleCheckboxGroup(groupSpecificCheckboxes, false);
        } else if ($checkbox.is($sendNewsletterToAllUsers)) {
          selectDefaultCheckboxes();
        }

        updateAll($checkbox);
      });
    });

    groupSpecificCheckboxes.forEach(($checkbox) => {
      $checkbox.on("change", () => {
        if ($checkbox.find("input[type='checkbox']").prop("checked")) {
          toggleCheckboxGroup(globalCheckboxes, false);
        }

        updateAll($checkbox);
      });
    });

    // Initialize visibility and ensure at least one checkbox is selected
    updateVisibility();
    ensureAtLeastOneCheckboxSelected();

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

      xhr.send(formData);
      updateConfirmRecipientsLink();
    });
  }
});

document.addEventListener("DOMContentLoaded", () => {
  const selectElement = document.querySelectorAll("[data-multiselect='true']");

  selectElement.forEach((container) => {
    const config = {
      plugins: ["remove_button", "dropdown_input"],
      allowEmptyOption: true
    };

    return new TomSelect(container, config);
  });
});
