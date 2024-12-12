import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("DOMContentLoaded", () => {
  const selectors = {
    form: document.querySelector(".form.newsletter_deliver"),
    sendToAllUsers: document.querySelector("#newsletter_send_to_all_users"),
    sendToVerifiedUsers: document.querySelector("#newsletter_send_to_verified_users"),
    sendToParticipants: document.querySelector("#newsletter_send_to_participants"),
    sendToFollowers: document.querySelector("#newsletter_send_to_followers"),
    sendToPrivateMembers: document.querySelector("#newsletter_send_to_private_members"),
    verificationTypesSelect: document.querySelector("#verification_types_for_select"),
    participatorySpacesForSelect: document.querySelector("#participatory_spaces_for_select"),
    deliverButton: document.querySelector("#deliver-button"),
    confirmRecipientsLink: document.querySelector("#confirm-recipients-link"),
    recipientsCount: document.querySelector("#recipients_count"),
    recipientsCountSpinner: document.querySelector("#recipients_count_spinner")
  };

  const inputs = {
    radioButtons: [selectors.sendToAllUsers, selectors.sendToVerifiedUsers],
    checkboxes: [selectors.sendToParticipants, selectors.sendToFollowers, selectors.sendToPrivateMembers]
  };

  const updateHiddenField = ($input) => {
    const hiddenInput = selectors.form.elements[$input.name];
    if (hiddenInput) {
      hiddenInput.value = $input.checked
        ? "1"
        : "0";
    }
  };

  const ensureAtLeastOneOptionSelected = () => {
    const isAnyChecked = [...inputs.radioButtons, ...inputs.checkboxes].some((input) => input.checked);
    if (!isAnyChecked) {
      selectors.sendToAllUsers.checked = true;
      updateHiddenField(selectors.sendToAllUsers);
    }
  };

  const updateConfirmRecipientsLink = () => {
    const params = new URLSearchParams(new FormData(selectors.form));
    const baseUrl = selectors.confirmRecipientsLink.dataset.baseUrl;
    if (baseUrl) {
      selectors.confirmRecipientsLink.setAttribute("href", `${baseUrl}?${params.toString()}`);
    }
  };

  const updateButtonAndLink = () => {
    const isAllUsersChecked = selectors.sendToAllUsers.checked;
    const isAnyChecked = [...inputs.radioButtons, ...inputs.checkboxes].some((input) => input.checked);
    selectors.deliverButton.style.display = isAllUsersChecked
      ? "inline-block"
      : "none";
    selectors.confirmRecipientsLink.classList.toggle("hidden", isAllUsersChecked || !isAnyChecked);
    updateConfirmRecipientsLink();
  };

  const updateSpacesVisibility = () => {
    const isAnySelectiveChecked = inputs.checkboxes.some((input) => input.checked);
    const isVerifiedChecked = selectors.sendToVerifiedUsers.checked;
    selectors.participatorySpacesForSelect.classList.toggle("hidden", !(isAnySelectiveChecked && !isVerifiedChecked));
  };

  const updateVerificationTypesVisibility = () => {
    selectors.verificationTypesSelect.classList.toggle("hidden", !selectors.sendToVerifiedUsers.checked);
  };

  const updateRecipientsCount = async () => {
    const url = selectors.form.dataset.recipientsCountNewsletterPath;
    if (!url) {
      return;
    }

    selectors.recipientsCountSpinner.classList.remove("hide");
    try {
      const response = await fetch(url, { method: "POST", body: new FormData(selectors.form) });
      const responseText = await response.text();
      selectors.recipientsCount.textContent = responseText;
    } catch (error) {
      console.error("Error fetching recipients count:", error);
    } finally {
      selectors.recipientsCountSpinner.classList.add("hide");
    }
  };

  const updateFormState = () => {
    [...inputs.radioButtons, ...inputs.checkboxes].forEach((input) => updateHiddenField(input));
    updateButtonAndLink();
    updateSpacesVisibility();
    updateVerificationTypesVisibility();
    ensureAtLeastOneOptionSelected();
    updateConfirmRecipientsLink();
    updateRecipientsCount();
  };

  const attachEventListeners = () => {
    inputs.radioButtons.forEach((radio) => {
      radio.addEventListener("change", () => {
        if (radio.checked) {
          inputs.radioButtons.forEach((rb) => {
            rb.checked = rb === radio;
          });
          inputs.checkboxes.forEach((checkbox) => {
            checkbox.checked = false;
          });
        }
        updateFormState();
      });
    });

    inputs.checkboxes.forEach((checkbox) => {
      checkbox.addEventListener("change", () => {
        if (checkbox.checked) {
          inputs.radioButtons.forEach((radio) => {
            radio.checked = false;
          });
        }
        updateFormState();
      });
    });

    selectors.form.addEventListener("change", () => updateFormState());
  };

  updateFormState();
  attachEventListeners();

  document.querySelectorAll("[data-multiselect='true']").forEach((container) => {
    const config = {
      plugins: ["remove_button", "dropdown_input"],
      allowEmptyOption: true
    };

    return new TomSelect(container, config);
  });

  document.querySelectorAll("#participatory_spaces_for_select select[data-multiselect='true']").forEach((selectTag) => {
    selectTag.addEventListener("change", () => {
      const selectedOptions = Array.from(selectTag.selectedOptions).map((option) => option.value);
      if (selectedOptions.includes("all")) {
        selectTag.querySelectorAll("option").forEach((option) => {
          option.selected = option.value !== "all";
        });
      } else if (!selectedOptions.length) {
        selectTag.querySelectorAll("option").forEach((option) => {
          option.selected = false;
        });
      }
    }, { once: true });
  });
});
