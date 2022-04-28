import Cookies from "js-cookie";

class ConsentManager {
  constructor(options) {
    // const categories = ["essential", "preferences", "analytics", "marketing"]
    this.options = options;
    this.cookie = Cookies.get("decidim-cookie");
    console.log("cookie", this.cookie);
    console.log("state", this.state);
    if (this.cookie) {
      this.state = JSON.parse(this.cookie);
      console.log("this.state", this.state);
    }
  }

  stateToCookie() {
    Cookies.set("decidim-cookie", JSON.stringify(this.state));
  }

  saveSettings(categories) {
    this.state = categories;
    this.stateToCookie();
  }

  acceptAll() {
    this.options.categories.forEach((category) => {
      this.state[category] = true;
    });
    this.stateToCookie();
  }

  rejectAll() {
    this.state = {
      essential: true
    }
    this.stateToCookie();
  }

  getState() {
    return this.state;
  }
}

export default ConsentManager
