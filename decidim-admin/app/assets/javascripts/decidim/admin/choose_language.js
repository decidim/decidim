$(() => {
  $("select.language-change").change(function () {
    let $select = $(this);
    let selectedValue = $select[0].value;
    let options = $select[0].children;
    let arr = Array.from(options);
    let selectedOption = arr.filter(function(opt) {
      return opt.value === selectedValue
    })
    let targetTabPane = selectedOption[0].attributes.href.value;
    let $tabsContent = $select.parent().parent().siblings();
    let $previousTab = $tabsContent.children(".is-active");
    $previousTab.removeClass("is-active");
    let $newTab = $tabsContent.children(targetTabPane);
    $newTab.addClass("is-active");
  })
});
