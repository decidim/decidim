/* eslint-disable no-invalid-this */

$(() => {
  $(".delete-current input[type='checkbox']").change(function () {
    if($(".delete-current input[type='checkbox']").prop("checked")) {
      $(".delete-current-warning").css("display","flex");
    } else {
      $(".delete-current-warning").css("display","none");
    }
  })
});
