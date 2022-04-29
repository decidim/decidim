import Cookies from "js-cookie";

class ConsentManager {
  constructor(categories) {
    // const categories = ["cc-essential", "cc-preferences", "cc-analytics", "cc-marketing"]
    this.categories = categories;
    this.cookie = Cookies.get("decidim-cookie");
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
    this.updateUi();
  }

  updateUi() {
    const modal = document.querySelector("#cc-modal");
    const categoryElements = modal.querySelectorAll(".category-wrapper");

    categoryElements.forEach((categoryEl) => {
      const categoryInput = categoryEl.querySelector("input");
      if (this.state && this.state[categoryInput.name]) {
        categoryInput.checked = true;
      } else if (!categoryInput.disabled) {
        categoryInput.checked = false;
      }
    });
  }

  saveSettings(categories) {
    this.updateState(categories);
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
