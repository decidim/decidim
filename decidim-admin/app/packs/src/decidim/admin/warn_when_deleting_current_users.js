/* eslint-disable no-invalid-this */

$(() => {
  $(".delete-current input[type='checkbox']").change(function () {
    if($(".delete-current input[type='checkbox']").prop("checked")) {
      $(".delete-current-warning").css("display","flex");
      $message = $(".delete-current input[type='checkbox']").attr("data-confirmmessage")
      $("#new_participatory_space_private_user_csv_import_").attr("onsubmit","return confirm('"+$message+"');")
    } else {
      $(".delete-current-warning").css("display","none");
      $("#new_participatory_space_private_user_csv_import_").removeAttr("onsubmit")
    }
  })
});
