// Choose a Proposal Answer template, get it by AJAX and add the Template in the Proposal Answer textarea
document.addEventListener("turbo:load", () => {
  const proposalAnswerTemplateChooser = document.getElementById("proposal_answer_template_chooser");
  if (proposalAnswerTemplateChooser) {
    proposalAnswerTemplateChooser.addEventListener("change", () => {
      const dropdown =  document.getElementById("proposal_answer_template_chooser");
      const url = dropdown.getAttribute("data-url");
      const templateId = dropdown.value;
      const proposalId = dropdown.dataset.proposal;

      if (templateId === "") {
        return;
      }
      fetch(`${new URL(url).pathname}?${new URLSearchParams({ id: templateId, proposalId: proposalId })}`).
        then((response) => {
          if (response.ok) {
            return response.json();
          }
          return Promise.reject(response);
        }).
        then((data) => {
          document.getElementById(`proposal_answer_internal_state_${data.state}`).click();

          for (const [key, value] of Object.entries(data.template)) {
            const editorContainer = document.querySelector(`[name="proposal_answer[answer_${key}]"]`)?.nextElementSibling;

            if (editorContainer) {
              // Editors are initialized lazily, so the ones in hidden language
              // tabs may not exist yet. Reveal the editor before accessing it.
              editorContainer.dispatchEvent(new CustomEvent("editor:reveal", { bubbles: true }));

              const editor = editorContainer.querySelector(".ProseMirror")?.editor;
              if (editor) {
                editor.commands.setContent(value, true);
              } else {
                // If the editor has not been initialized synchronously, wait
                // for its initialization before inserting the content.
                editorContainer.addEventListener(
                  "editor:initialized",
                  (event) => event.detail.editor.commands.setContent(value, true),
                  { once: true }
                );
              }
            }
          }
        }).
        catch((response) => {
          response.json().then((data) => {
            const el = document.createElement("p");
            el.classList.add("text-alert");
            el.textContent = data.msg;
            dropdown.after(el);
          });
        });
    });
  }
});
