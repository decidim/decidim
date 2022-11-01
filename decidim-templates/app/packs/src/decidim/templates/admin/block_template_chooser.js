$(() => {
  $("#block_template_chooser").change(function() {
    let dropDown =  $("#block_template_chooser");
    $.getJSON(dropDown.data("url"), {
      id: dropDown.val()
    }).done(function(data) {
      $("#block_user_justification").val(data.template);
     });
  });
});
