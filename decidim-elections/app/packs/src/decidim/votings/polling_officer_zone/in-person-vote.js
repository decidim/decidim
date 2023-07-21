$(() => {
  $("#person_voted_checkbox").on("change", (event) => {
    $("#submit_complete_voting").attr("disabled", !$(event.target).is(":checked"));
  });
});
