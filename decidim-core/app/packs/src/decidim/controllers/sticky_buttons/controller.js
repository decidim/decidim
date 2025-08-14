import { Controller } from "@hotwired/stimulus"
import { screens } from "tailwindcss/defaultTheme"

export default class extends Controller {
  connect() {
    this.footer = document.querySelector("footer");
    // this.stickyButtons = document.querySelector("[data-sticky-buttons]");

    this.adjustCtasButtons();

    document.addEventListener("scroll", () => {
      this.adjustCtasButtons();
    });

    document.addEventListener("on:toggle", () => {
      this.adjustCtasButtons();
    });

    window.addEventListener("resize", () => {
      this.adjustCtasButtons();
    });
  }

  /**
   * Checks if the current viewport matches the specified screen size
   *
   * @param {('sm'|'md'|'lg'|'xl'|'2xl')} key - The screen size key to check
   * @returns {boolean} - Returns true if the screen size corresponds with the key
   */
  isScreenSize(key) {
    return window.matchMedia(`(min-width: ${screens[key]})`).matches;
  }


  /**
   * Adjusts the footer margin based on sticky buttons presence and screen size
   * On medium screens and larger, no margin adjustment is needed
   * On smaller screens, adds margin equal to the sticky buttons height
   * @returns {void}
   */
  adjustCtasButtons() {
    if (!this.element || !this.footer) {
      return;
    }

    if (this.isScreenSize("md")) {
      this.footer.style.marginBottom = "0px";
      return;
    }

    const marginBottom = this.element.offsetHeight;
    this.footer.style.marginBottom = `${marginBottom}px`;
  }

}
