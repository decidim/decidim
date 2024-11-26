class AdminAccountabilityImportsComponent {
  run() {
    this.bindEvents();
  }

  bindEvents() {
    const $form = this.getForm();
    const $selects = $form.find("select");

    $selects.each((_i, select) => {
      $(select).on("change", this.onSelectChange.bind(this));
    });
  }

  onSelectChange() {
    const $form = this.getForm();
    const formUrl = $form.data("form-url");

    $form.find("input[name='authenticity_token']").remove();
    $form.attr("action", formUrl);
    $form.attr("method", "get");
    $form.submit();
  }

  getForm() {
    return $("#new_import_component");
  }
}

window.Decidim.AdminAccountabilityImportsComponent = AdminAccountabilityImportsComponent;
const component = new AdminAccountabilityImportsComponent();

component.run();
