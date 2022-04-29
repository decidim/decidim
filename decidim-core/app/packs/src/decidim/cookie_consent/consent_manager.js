import Cookies from "js-cookie";

class ConsentManager {
  constructor(options) {
    // const categories = ["cc-essential", "cc-preferences", "cc-analytics", "cc-marketing"]
    this.modal = options.modal;
    this.categories = options.categories;
    this.cookie = Cookies.get(options.cookieName);
    console.log("cookie", this.cookie);
    console.log("state", this.state);
    if (this.cookie) {
      this.state = JSON.parse(this.cookie);
      console.log("this.state", this.state);
    }
  }

  updateState(newState) {
    this.state = newState;
    Cookies.set("decidim-cookie", JSON.stringify(this.state));
    this.updateModalSelections();
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
