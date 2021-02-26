/* globals svg4everybody */

window.Decidim = window.Decidim || {};

$(() => {
  if (window.Decidim.DataPicker) {
    window.theDataPicker = new window.Decidim.DataPicker($(".data-picker"));
  }
  if (window.Decidim.CheckBoxesTree) {
    window.theCheckBoxesTree = new window.Decidim.CheckBoxesTree();
  }

  $(document).foundation();

  if (window.Decidim.fixDropdownMenus) {
    window.Decidim.fixDropdownMenus();
  }

  svg4everybody();

  // Prevent data-open buttons e.g. from submitting the underlying form in
  // authorized action buttons.
  $("[data-open]").on("click", (event) => {
    event.preventDefault();
  });

  if (window.Decidim.formDatePicker) {
    window.Decidim.formDatePicker();
  }

  if (window.Decidim.quillEditor) {
    window.Decidim.quillEditor();
  }
});
