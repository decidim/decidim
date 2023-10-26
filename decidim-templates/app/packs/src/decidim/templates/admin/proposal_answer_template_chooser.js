// Choose a Proposal Answer template, get it by AJAX and add the Template in the Proposal Answer textarea
document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("proposal_answer_template_chooser").addEventListener("change", () => {
    const dropdown =  document.getElementById("proposal_answer_template_chooser");
    const url = dropdown.getAttribute("data-url");
    const templateId = dropdown.value;
    const proposalId = dropdown.dataset.proposal;

    if (templateId === "") {
      return;
    }
    fetch(`${new URL(url).pathname}?${new URLSearchParams({ id: templateId, proposalId: proposalId })}`).
      then((response) => response.json()).
      then((data) => {
        document.getElementById(`proposal_answer_internal_state_${data.state}`).click();

        let editorContainer = null;
        for (const [key, value] of Object.entries(data.template)) {
          editorContainer = document.querySelector(`[name="proposal_answer[answer_${key}]"]`).nextElementSibling;
          let editor = editorContainer.querySelector(".ProseMirror").editor;

          editor.commands.setContent(value, true);
        }
      })
  });
});
