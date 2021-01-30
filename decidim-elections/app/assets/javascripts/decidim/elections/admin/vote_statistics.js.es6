// fetches Vote stats every 3 seconds

$(() => {
  setInterval(function() {
    $("#vote-stats").load($("#vote-stats").data("refreshUrl"));
  }, 3000);
})
