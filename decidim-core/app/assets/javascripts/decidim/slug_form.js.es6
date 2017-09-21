$(() => {
  const $wrapper = $(".slug");
  const $input = $wrapper.find("input");
  const $target = $wrapper.find("span.slug-url-value");

  $input.on("keyup", (event) => {
    $target.html(event.target.value);
  });
});
