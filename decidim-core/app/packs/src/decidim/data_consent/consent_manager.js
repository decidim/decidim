import Cookies from "js-cookie";

class ConsentManager {
  // Options should contain the following keys:
  // - modal - HTML element of the data consent modal (e.g. "<div id="dc-modal">Foo bar</div>")
  // - categories - Available data consent categories (e.g. ["essential", "preferences", "analytics", "marketing"])
  // - cookieName - Name of the cookie saved in the browser (e.g. "decidim-consent")
  // - warningElement - HTML element to be shown when user has not given the necessary data consent to display the content.
  constructor(options) {
    this.modal = options.modal;
    this.categories = options.categories;
    this.cookieName = options.cookieName;
    this.cookie = Cookies.get(this.cookieName);
    this.warningElement = options.warningElement;
    if (this.cookie) {
      this.updateState(JSON.parse(this.cookie));
    } else {
      this.updateState({});
    }
  }

  updateState(newState) {
    this.state = newState;
    Cookies.set(this.cookieName, JSON.stringify(this.state), {
      domain: document.location.host.split(":")[0],
      sameSite: "Lax",
      expires: 365,
      secure: window.location.protocol === "https:"
    });
    this.updateModalSelections();
    this.triggerState();
  }

  triggerJavaScripts() {
    document.querySelectorAll("script[type='text/plain'][data-consent]").forEach((script) => {
      if (this.state[script.dataset.consent]) {
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
        if (original.childNodes && original.childNodes.length) {
          const content = Array.from(original.childNodes).find((childNode) => {
            return childNode.nodeType === Node.COMMENT_NODE;
          });
          if (!content) {
            return;
          }
          const newElement = document.createElement("div");
          newElement.innerHTML = content.nodeValue;
          original.parentNode.replaceChild(newElement.firstElementChild, original);
        }
      });
    } else {
      document.querySelectorAll("iframe").forEach((original) => {
        const newElement = document.createElement("div");
        newElement.className = "disabled-iframe";
        newElement.appendChild(document.createComment(`${original.outerHTML}`));
        original.parentNode.replaceChild(newElement, original);
      });
    }
  }

  triggerWarnings() {
    document.querySelectorAll(".disabled-iframe").forEach((original) => {
      if (original.querySelector(".dataconsent-warning")) {
        return;
      }

      let cloned = this.warningElement.cloneNode(true);
      cloned.classList.remove("hide");
      cloned.hidden = false;
      original.appendChild(cloned);
    });
  }

  triggerState() {
    this.triggerJavaScripts();
    this.triggerIframes();
    this.triggerWarnings();
  }

  allAccepted() {
    return this.categories.every((category) => {
      return this.state[category] === true;
    });
  }

  updateModalSelections() {
    const categoryElements = this.modal.querySelectorAll("[data-id]");

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
    const newState = {};
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
