export const initializeReverseGeocoding = function() {
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
      button.dataset.originalContent = button.innerHTML;
      button.textContent = "";
      const spinner = document.createElement("span");
      spinner.className = "geocoding__spinner";
      button.appendChild(spinner);
      button.append(` ${button.dataset.locatingText || "Locating..."}`);
      button.setAttribute("disabled", true);
      button.classList.add("geocoding__button--locating");
    } else {
      if (button.dataset.originalContent) {
        button.innerHTML = button.dataset.originalContent;
      }
      button.removeAttribute("disabled");
      button.classList.remove("geocoding__button--locating");
    }
  };

  document.querySelectorAll(".geocoding__button").forEach((button) => {
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

          $.post(url, { latitude: coordinates[0], longitude: coordinates[1] }, (data) => {
            input.value = data.address;
            $(input).trigger("geocoder-suggest-coordinates.decidim", [coordinates]);
            setLocating(target, false);
          }).fail((xhr, status, error) => {
            info(input, `${errorNoLocation} ${error}`);
            setLocating(target, false);
          });

        }, (evt) => {
          info(input, `${errorNoLocation} ${evt.message}`);
          setLocating(target, false);
        }, {
          enableHighAccuracy: true
        });
      } else {
        info(input, errorUnsupported);
      }
    });
  });
};
