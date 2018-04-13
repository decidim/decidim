// = require_self

/**
 * When changing an authorization handler selection, show its options
 */
$(() => {
  $("select[id$=authorization_handler_name").on("change", (event) => {
    let url = $(event.target).data("authorization-handler-path").replace(":handler_name", event.target.value)

    $.ajax({ url: url, dataType: "script" });
  });
});
