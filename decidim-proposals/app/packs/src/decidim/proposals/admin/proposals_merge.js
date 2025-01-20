import { createDialog } from "src/decidim/a11y"
import createEditor from "src/decidim/editor";
import attachGeocoding from "src/decidim/geocoding/attach_input";
import { initializeUploadFields } from "src/decidim/direct_uploads/upload_field";
import { initializeReverseGeocoding } from "src/decidim/geocoding/reverse_geocoding"

document.addEventListener("decidim:loaded", () => {
  document.querySelectorAll('button[data-action="merge-proposals"]').forEach((button) => {
    const url = button.dataset.mergeUrl;
    const drawer = window.Decidim.currentDialogs[button.dataset.mergeDialog];
    const container = drawer.dialog.querySelector("#merge-proposals-actions");

    // Handles changes on the form
    const activateDrawerForm = () => {
      const saveForm = drawer.dialog.querySelector("#form-merge-proposals");

      // Handles editor initialization
      saveForm.querySelectorAll(".editor-container").forEach((element) => createEditor(element));
      const form = document.querySelector(".proposals_merge_form_admin");
      const editorInput = form.querySelector(".editor-input");
      editorInput.style.height = `${parseFloat(window.getComputedStyle(editorInput).height) / 2}px`;

      // Handles meeting checkbox
      if (form) {
        const proposalCreatedInMeeting = form.querySelector("#proposals_merge_created_in_meeting");
        const proposalMeeting = form.querySelector("#proposals_merge_meeting");

        const toggleDisabledHiddenFields = () => {
          const enabledMeeting = proposalCreatedInMeeting.checked;
          proposalMeeting.querySelector("select").setAttribute("disabled", "disabled");

          proposalMeeting.classList.add("hidden");

          if (enabledMeeting) {
            proposalMeeting.querySelector("select").removeAttribute("disabled");
            proposalMeeting.classList.remove("hidden");
          }
        };

        proposalCreatedInMeeting.addEventListener("change", toggleDisabledHiddenFields);
        toggleDisabledHiddenFields();
      }

      // Handles address input (requires jQuery for the moment)
      attachGeocoding($(document.getElementById("proposals_merge_address")));

      // Handles address reverse_geocoding initialization
      initializeReverseGeocoding()

      // Handles upload files initialization
      saveForm.querySelectorAll("[data-dialog]").forEach((component) => createDialog(component));
      initializeUploadFields(saveForm.querySelectorAll("button[data-upload]"));

      // Handles form errors and success
      if (saveForm) {
        saveForm.addEventListener("ajax:success", (event) => {
          const response = event.detail[0];

          if (response.status === "ok") {
            window.location.reload();
            drawer.close();
          } else {
            window.location.href = response.redirect_url;
          }
        });

        saveForm.addEventListener("ajax:error", (event) => {
          const response = event.detail[2];
          container.innerHTML = response.responseText;
          activateDrawerForm();
        });
      }
    }

    const fetchUrl = (urlToFetch) => {
      container.classList.add("spinner-container");
      fetch(urlToFetch).then((response) => response.text()).then((html) => {
        container.innerHTML = html;
        container.classList.remove("spinner-container");
        // We still need foundation for form validations
        $(container).foundation();
        activateDrawerForm();
      });
    };

    button.addEventListener("click", () => {
      const selectedProposals = Array.from(document.querySelectorAll(".js-check-all-proposal:checked")).map((checkbox) => checkbox.value);
      const uniqueProposals = [...new Set(selectedProposals)];

      const queryParams = uniqueProposals.map((id) => `proposal_ids[]=${encodeURIComponent(id)}`).join("&")
      fetchUrl(`${url}?${queryParams}`);
      drawer.open();
    });
  })
});
