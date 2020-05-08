$(() => {
  $("input.geocoder").on("change", (event) => {
    const $input = $(event.currentTarget);
    const $list = $($input.data("list"));
    const query = $input.val();

    $list.empty();
    // todo add loading feedback
    
    $.ajax({
      type: "get",
      url: $input.data(`${url}?q=${query}`),
      success: (data) => {
        console.log(data);

        data.forEach((result) => {
          $list.append(`<li class="geocoder-result" data-coords="${result.coordinates}">${result.full_address}</li>`)
        });
      },
      error: function (request, status, error) {
        
      }
    });
  });
});
