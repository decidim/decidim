class AdminAccountabilityImportsComponent {
  run() {
    this.bindEvents();
  }

  bindEvents() {
    const form = this.getForm();
    const selects = form.querySelectorAll("select");

    selects.forEach((select) => {
      select.addEventListener("change", this.onSelectChange.bind(this));
    });
  }

  onSelectChange() {
    const form = this.getForm();
    const formUrl = form.dataset.formUrl;

    // Remove authenticity token input if it exists
    const tokenInput = form.querySelector("input[name='authenticity_token']");
    if (tokenInput) {
      tokenInput.remove();
    }

    form.setAttribute("action", formUrl);
    form.setAttribute("method", "get");
    form.submit();
  }

  getForm() {
    return document.getElementById("new_import_component");
  }
}

window.Decidim.AdminAccountabilityImportsComponent = AdminAccountabilityImportsComponent;
const component = new AdminAccountabilityImportsComponent();

component.run();
