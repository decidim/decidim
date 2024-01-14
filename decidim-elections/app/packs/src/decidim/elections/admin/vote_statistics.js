/* eslint-disable no-inline-comments */
/* eslint-disable line-comment-position */
// fetches Vote stats every 3 seconds

$(() => {
  const WAIT_TIME_MS = 3000; // 3s
  const url = $("#vote-stats").data("refreshUrl");

  if (url) {
    setInterval(function() {
      $("#vote-stats").load(url);
    }, WAIT_TIME_MS);
  }
})
