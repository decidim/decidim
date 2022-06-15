/* Fallback for non-handled failed promises */
window.addEventListener("unhandledrejection", (event) => {
  $("#server-failure .tech-info").html(event.reason);
  $("#server-failure").foundation("open");
});

