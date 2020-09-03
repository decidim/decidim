/* eslint-disable no-invalid-this */

$(() => {
  $("select.language-change").change(function () {
    let $select = $(this);
    let selectedValue = this.value;
    let options = $select[0].children;
    let arr = Array.from(options);
    let selectedOption = arr.filter(function(opt) {
      return opt.value === selectedValue
    })
    let targetTabPane = selectedOption[0].attributes.href.value;
    let $tabsContent = $select.parent().parent().siblings();
    $tabsContent.children(".is-active").removeClass("is-active");
    $tabsContent.children(targetTabPane).addClass("is-active");
  })
});
