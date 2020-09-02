$(() => {
  $("select.language-change").change(function () {
    var selectedValue = this.value;
    var $select = $(this);
    var options = $select[0].children;
    var arr = Array.from(options);
    var selectedOption = arr.filter(function(opt) {
      return opt.value == selectedValue
    })
    var targetTabPane = selectedOption[0]["attributes"].href["value"];
    var $tabsContent = $select.parent().parent().siblings();
    $previousTab = $tabsContent.children('.is-active');
    $previousTab.removeClass('is-active');
    $newTab = $tabsContent.children(targetTabPane);
    $newTab.addClass("is-active");
  })
});