$(() => {
  $(document).on("click", "a[data-open-url],button[data-open-url]", (event) => {
    event.preventDefault();
    const link = event.currentTarget;
    const $modal = $(`#${link.dataset.open}`);
    $modal.html("<div class='loading-spinner'></div>");
    $.ajax({
      type: "get",
      url: link.dataset.openUrl,
      success: (html) => {
        const $html = $(html);
        $modal.html($html);
        $html.foundation();
      },
      error: function (request, status, error) {
        $modal.html(`<h3>${status}</h3><p>${error}</p>`);
      }
    });
  });
});
