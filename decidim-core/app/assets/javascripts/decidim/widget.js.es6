window.addEventListener("message", function (event) {
  if (event.data.type === "GET_HEIGHT") {
    let body = document.body;
    let html = document.documentElement;
    let height = Math.max(body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight);

    parent.postMessage({ type: "SET_HEIGHT", height: height }, "*");
  }
});
