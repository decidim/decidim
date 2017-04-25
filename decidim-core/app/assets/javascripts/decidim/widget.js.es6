window.addEventListener("message", (event) => {
  if (event.data.type === "GET_HEIGHT") {
    const body = document.body;
    const html = document.documentElement;
    const height = Math.max(body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight);

    parent.postMessage({ type: "SET_HEIGHT", height: height }, "*");
  }
});

$(() => {
  // Set target blank for all widget links.
  $('a').attr('target', '_blank');
});
