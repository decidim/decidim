$(() => {
  const $input = $("#newsletter_tos");
  let val = 0;

  $input.on("change", () => {
    if (val % 2 === 0) {
      $input.val("1");
    } else {
      $input.val("0");
    }

    $.ajax({
      type: "POST",
      beforeSend: function(xhr) {xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr("content"))},
      url: $input.data("url"),
      data: `newsletter_notification=${$input.val()}`
    });


    val += 1;
  });
});
