import Counter from "src/decidim/accountability/admin/index/counter";
import ActionButton from "src/decidim/accountability/admin/index/action_button";
import ActionForm from "src/decidim/accountability/admin/index/action_form";
import ActionSelector from "src/decidim/accountability/admin/index/action_selector";
import SelectAll from "src/decidim/accountability/admin/index/select_all";

$(() => {
  const counter = new Counter();
  const actionButton = new ActionButton(counter);
  const actionForm = new ActionForm(counter);
  const actionSelector = new ActionSelector();
  const selectAll = new SelectAll(counter);

  counter.init();
  actionButton.init();
  actionForm.init();
  actionSelector.init();
  selectAll.init();
})
