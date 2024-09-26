document.addEventListener("DOMContentLoaded", () => {
  const info = (target, msg) => {
    const label = target.closest("label");
    label.querySelectorAll(".form-error").forEach((el) => el.remove());
    if (msg) {
      const error = document.createElement("span");
      error.className = "form-error";
      error.textContent = msg;
      label.appendChild(error);
      error.style.display = "block";
    }
  };

  const setLocating = (button, enable) => {
    if (enable) {
      button.setAttribute("disabled", true);
    } else {
      button.removeAttribute("disabled");
    }
  };

  document.querySelectorAll(".user-device-location button").forEach((button) => {
    button.addEventListener("click", (event) => {
      const target = event.target;
      if (target.disabled) {
        return;
      }

      const input = document.getElementById(target.dataset.input);
      const errorNoLocation = target.dataset.errorNoLocation;
      const errorUnsupported = target.dataset.errorUnsupported;
      const url = target.dataset.url;

      if (navigator.geolocation) {
        setLocating(target, true);
        navigator.geolocation.getCurrentPosition((position) => {
          const coordinates = [position.coords.latitude, position.coords.longitude];

          // reverse geolocation
          $.post(url, { latitude: coordinates[0], longitude: coordinates[1] }, (data) => {
            input.value = data.address;
            $(input).trigger("geocoder-suggest-coordinates.decidim", [coordinates]);
          }).fail((xhr, status, error) => {
            info(input, `${errorNoLocation} ${error}`);
          });

          setLocating(target, false);

        }, (evt) => {
          info(input, `${errorNoLocation} ${evt.message}`);
          target.removeAttribute("disabled");
        }, {
          enableHighAccuracy: true
        });
      } else {
        info(input, errorUnsupported);
      }
    });
  });
});
