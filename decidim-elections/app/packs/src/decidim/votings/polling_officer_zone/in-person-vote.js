$(() => {
  $("#person_voted_checkbox").on("change", (event) => {
    $("#submit_complete_voting").toggleClass("disabled", !$(event.target).is(":checked"));
  });
});
