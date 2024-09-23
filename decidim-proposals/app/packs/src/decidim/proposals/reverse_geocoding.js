$(() => {
  const info = ($target, msg) => {
    const $label = $target.closest("label")
    $label.find(".form-error").remove();
    if (msg) {
      $('<span class="form-error"/>').text(msg).appendTo($label).show();
    }
  };

  const setLocating = ($button, enable) => {
    if (enable) {
      $button.attr("disabled", true);
    } else {
      $button.attr("disabled", false);
    }
  }

  $(".user-device-location button").on("click", (event) => {
    const $this = $(event.target);
    if ($this.is(":disabled")) {
      return;
    }

    const $input = $(`#${event.target.dataset.input}`);
    const errorNoLocation = event.target.dataset.errorNoLocation;
    const errorUnsupported = event.target.dataset.errorUnsupported;
    const url = event.target.dataset.url;

    if (navigator.geolocation) {
      setLocating($this, true);
      navigator.geolocation.getCurrentPosition((position) => {
        const coordinates  = [position.coords.latitude, position.coords.longitude];
        // reverse geolocation
        $.post(url, { latitude: coordinates[0], longitude: coordinates[1] }, (data) => {
          $input.val(data.address)
        })
        setLocating($this, false);
        $input.trigger(
          "geocoder-suggest-coordinates.decidim",
          [coordinates]
        );
      }, (evt) => {
        info($input, `${errorNoLocation} ${evt.message}`);
        $this.attr("disabled", false);
      }, {
        enableHighAccuracy: true
      });
    } else {
      info($input, errorUnsupported);
    }
  });
});
