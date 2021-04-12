$(() => {
  const $inputs = $("input[data-autojump]");

  // Initialize
  $inputs.on("keydown", (event) => {
    // Don't do anything if there is selected text
    if (event.target.selectionStart != event.target.selectionEnd) {
      return;
    }

    if (event.originalEvent.key.length == 1 && event.target.dataset.jumpNext) {
      if (event.target.value.length == event.target.dataset.maxLength) {
        event.preventDefault();
        setTimeout(() => {
          const next = $(event.target.dataset.jumpNext);
          next.val(event.originalEvent.key);
          next.trigger("focus");
        }, 1);
      }
    } else if (
      event.originalEvent.keyCode == 8 &&
      event.target.dataset.jumpPrev
    ) {
      if (event.target.value == "") {
        event.preventDefault();
        setTimeout(() => {
          const prev = $(event.target.dataset.jumpPrev);
          prev.val(prev.val().slice(0, -1));
          prev.trigger("focus");
        }, 1);
      }
    }
  });
});
