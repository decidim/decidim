import Cookies from "js-cookie";

class ConsentManager {
  // Options should contain the following keys:
  // - modal - HTML element of the cookie consent modal (e.g. "<div id="cc-modal">Foo bar</div>")
  // - categories - Available cookie categories (e.g. ["essential", "preferences", "analytics", "marketing"])
  // - cookieName - Name of the cookie saved in browser (e.g. "decidim-cookie")
  constructor(options) {
    this.modal = options.modal;
    this.categories = options.categories;
    this.cookie = Cookies.get(options.cookieName);
    this.warningElement = document.querySelector(".cookie-warning");
    if (this.cookie) {
      this.updateState(JSON.parse(this.cookie));
    }
  }

  updateState(newState) {
    this.state = newState;
    Cookies.set("decidim-cookie", JSON.stringify(this.state));
    this.updateModalSelections();
    this.triggerState();
  }

  triggerJavaScripts() {
    document.querySelectorAll("script[type='text/plain'][data-cookiecategory]").forEach((script) => {
      if (this.state[script.dataset.cookiecategory]) {
        const activeScript = document.createElement("script");
        if (script.src.length > 0) {
          activeScript.src = script.src;
        } else {
          activeScript.innerHTML = script.innerHTML;
        }
        script.parentNode.replaceChild(activeScript, script);
      }
    });

    const event = new CustomEvent("dataconsent", { detail: this.state });
    document.dispatchEvent(event);
  }

  triggerIframes() {
    if (this.allAccepted()) {
      document.querySelectorAll(".disabled-iframe").forEach((original) => {
        let newElement = this.transformElement(original, "iframe");
        newElement.className = original.classList.toString().replace("disabled-iframe", "");
        original.parentElement.appendChild(newElement);
        original.remove();
      })
    } else {
      document.querySelectorAll("iframe").forEach((original) => {
        const newElement = this.transformElement(original, "div");
        newElement.className = `disabled-iframe ${original.classList.toString()}`;
        original.parentElement.appendChild(newElement);
        original.remove();
      })
    }
  }

  transformElement(original, targetType) {
    const newElement = document.createElement(targetType);
    ["src", "allow", "frameborder", "style", "loading"].forEach((attribute) => {
      newElement.setAttribute(attribute, original.getAttribute(attribute));
    })

    return newElement;
  }

  triggerWarnings() {
    document.querySelectorAll(".disabled-iframe").forEach((original) => {
      if (original.querySelector(".cookie-warning")) {
        return;
      }

      let cloned = this.warningElement.cloneNode(true);
      cloned.classList.remove("hide");
      original.appendChild(cloned);
    });
  }

  triggerState() {
    this.triggerJavaScripts();
    this.triggerIframes();
    this.triggerWarnings();
  }

  allAccepted() {
    let allAccepted = true;
    this.categories.forEach((category) => {
      if (!this.state || !this.state[category]) {
        allAccepted = false;
      }
    })
    return allAccepted;
  }

  updateModalSelections() {
    const categoryElements = this.modal.querySelectorAll(".category-wrapper");

    categoryElements.forEach((categoryEl) => {
      const categoryInput = categoryEl.querySelector("input");
      if (this.state && this.state[categoryInput.name]) {
        categoryInput.checked = true;
      } else if (!categoryInput.disabled) {
        categoryInput.checked = false;
      }
    });
  }

  saveSettings(newState) {
    this.updateState(newState);
  }

  acceptAll() {
    let newState = {};
    this.categories.forEach((category) => {
      newState[category] = true;
    });
    this.updateState(newState);
  }

  rejectAll() {
    this.updateState({
      essential: true
    });
  }

  getState() {
    return this.state;
  }
}

export default ConsentManager
