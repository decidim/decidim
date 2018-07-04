$(() => {
  $(document).on("click", "a[data-open-url],button[data-open-url]", (event) => {
    event.preventDefault();
    const $link = $(event.currentTarget);
    const $modal = $(`#${$link.data("open")}`);
    $modal.html("<div class='loading-spinner'></div>");
    $.ajax({
      type: "get",
      url: $link.data("open-url"),
      success: (html) => {
        const $html = $(html);
        $modal.html($html);
        $html.foundation();
      }
    });
  });
});
