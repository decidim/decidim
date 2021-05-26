/* eslint-disable no-inline-comments */
/* eslint-disable line-comment-position */
// fetches Vote stats every 3 seconds

$(() => {
  const WAIT_TIME_MS = 3000; // 3s

  setInterval(function() {
    $("#vote-stats").load($("#vote-stats").data("refreshUrl"));
  }, WAIT_TIME_MS);
})
