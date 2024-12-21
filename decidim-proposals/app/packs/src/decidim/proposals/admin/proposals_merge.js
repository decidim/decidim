import AutoComplete from "src/decidim/autocomplete";
import createEditor from "src/decidim/editor";
import attachGeocoding from "src/decidim/geocoding/attach_input"


document.addEventListener("decidim:loaded", () => {
  document.querySelectorAll('button[data-action="merge-proposals"]').forEach((button) => {
    const url = button.dataset.mergeUrl;
    const drawer = window.Decidim.currentDialogs[button.dataset.mergeDialog];
    const container = drawer.dialog.querySelector(".js-bulk-action-form");

    // Handles geocoding_field
    const geocoding = () => {
      document.querySelectorAll("[data-decidim-geocoding]").forEach((el) => {
        if (el.dataset.geocodingInitialized) return;
        el.dataset.geocodingInitialized = true;
        const input = el;
      
        const autoComplete = new AutoComplete(el, {
          mode: "single",
          dataMatchKeys: ["value"],
          dataSource: (query, callback) => {
            const event = new CustomEvent("geocoder-suggest.decidim", {
              detail: { query, callback }
            });
            input.dispatchEvent(event);
          }
        });
      
        el.addEventListener("selection", (event) => {
          const selectedItem = event.detail.selection.value;
      
          const suggestSelectEvent = new CustomEvent("geocoder-suggest-select.decidim", {
            detail: selectedItem
          });
          input.dispatchEvent(suggestSelectEvent);
      
          // Check for coordinates in the selected item
          if (selectedItem.coordinates) {
            const coordinatesEvent = new CustomEvent("geocoder-suggest-coordinates.decidim", {
              detail: selectedItem.coordinates
            });
            input.dispatchEvent(coordinatesEvent);
          }
        });
      });
    }

    // Handles editor initialization
    const editorInitializer = () => {
      container.querySelectorAll(".editor-container").forEach((element) => createEditor(element));
    }

    // Handles active drawer form
    const activateDrawerForm = () => {
      const form = document.querySelector(".proposals_merge_form_admin");
      
      if (form) {
        const proposalCreatedInMeeting = form.querySelector("#proposal_created_in_meeting");
        const proposalMeeting = form.querySelector("#proposals_merge_meeting");
    
        const toggleDisabledHiddenFields = () => {
          const enabledMeeting = proposalCreatedInMeeting.checked;
          const meetingSelect = proposalMeeting.querySelector("select");
    
          meetingSelect.disabled = !enabledMeeting;
          proposalMeeting.classList.toggle("hide", !enabledMeeting);
        };

        proposalCreatedInMeeting.addEventListener("change", toggleDisabledHiddenFields);
        toggleDisabledHiddenFields();

        const proposalAddress = form.querySelector("#proposals_merge_address");
        if (proposalAddress) {
          attachGeocoding(proposalAddress);
        }
      }
    }

    const fetchUrl = (url) => {
      container.classList.add("spinner-container");
      fetch(url).then((response) => response.text()).then((html) => {
        container.innerHTML = html;
        container.classList.remove("spinner-container");
        activateDrawerForm();
        editorInitializer()
        geocoding()
      });
    };

    button.addEventListener("click", (event) => {
      const selectedProposals = Array.from(document.querySelectorAll(".js-check-all-proposal:checked")).map((checkbox) => checkbox.value);
      const uniqueProposals = [...new Set(selectedProposals)];

      const queryParams = uniqueProposals.map((id) => `proposal_ids[]=${encodeURIComponent(id)}`).join("&")
      fetchUrl(`${url}?${queryParams}`);
      drawer.open();
    });
  })

});




  
