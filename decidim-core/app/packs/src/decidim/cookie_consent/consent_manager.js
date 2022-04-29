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

  triggerState() {
    document.querySelectorAll("script[type='text/plain'][data-cookiecategory]").forEach((script) => {
      console.log("script", script);
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
