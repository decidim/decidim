// Choose a Block User Message template, get it by AJAX and add the Template in the justification textarea
document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("block_template_chooser").addEventListener("change", () => {
    const dropdown =  document.getElementById("block_template_chooser");
    const url = dropdown.getAttribute("data-url");
    const templateId = dropdown.value;

    if (templateId === "") {
      return;
    }
    fetch(`${new URL(url).pathname}?${new URLSearchParams({ id: templateId })}`).
      then((response) => response.json()).
      then((data) => {
        document.getElementById("block_user_justification").value = data.template;
      })
  });
});
