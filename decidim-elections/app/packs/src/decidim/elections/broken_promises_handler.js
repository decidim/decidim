/* Fallback for non-handled failed promises */
window.addEventListener("unhandledrejection", (event) => {
  console.log("broken", event)
  $("#server-failure .tech-info").html(event.reason);
  if (event.reason.toString().indexOf("fetch") === -1) {
    $("#server-failure .communication_error").addClass("hide");  
    $("#server-failure .generic_error").removeClass("hide"); 
  }
  $("#server-failure").foundation("open");
});

