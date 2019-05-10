$(() => {
  const $form = $(".form.edit_component");

  if ($form.length > 0) {
    const $checkbox = $(".participatory_texts_disabled");

    if ($checkbox.length > 0) {
      const $text = $checkbox[0].dataset.text

      $checkbox.parent().after(`<p class="help-text">${$text}</p`)
    }
  }
});
