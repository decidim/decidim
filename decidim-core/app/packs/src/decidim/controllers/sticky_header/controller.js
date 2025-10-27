import { Controller } from "@hotwired/stimulus"
import { screens } from "tailwindcss/defaultTheme"

export default class extends Controller {
  connect() {
    this.prevScroll = window.scrollY;

    // Set the initial margin for the menu bar container
    this.fixMenuBarContainerMargin();

    // Attach event listeners for page load and window resize events
    this.setupEventListeners();

    // Set up the scroll event handler for sticky header behavior
    this.setupScrollHandler();
  }

  /**
   * Determines if the current screen size matches or is smaller than the specified breakpoint.
   * Uses Tailwind CSS screen breakpoints for responsive behavior.
   *
   * @param {string} key - The Tailwind CSS screen breakpoint key (e.g., 'md', 'lg')
   * @returns {boolean} True if the screen is at or below the specified breakpoint
   */
  isMaxScreenSize(key) {
    return window.matchMedia(`(max-width: ${screens[key]})`).matches;
  }

  /**
   * Dynamically adjusts the top margin of the menu bar container to accommodate
   * the sticky header height. This prevents content from being hidden behind
   * the fixed sticky header.
   *
   * The margin is only applied on mobile devices (screens smaller than 'md' breakpoint)
   * to ensure proper spacing when multiple header elements are present, such as
   * omnipresent banner, admin bar, and offline banner.
   * @returns {void}
   */
  fixMenuBarContainerMargin() {
    // Locate the menu bar container element
    const menuBarContainer = document.querySelector("#menu-bar-container");

    // Calculate margin based on screen size and sticky header height
    const marginTop = this.isMaxScreenSize("md")
      ? this.element.offsetHeight
      : 0;

    // Apply the calculated margin to the menu bar container
    if (menuBarContainer) {
      menuBarContainer.style.marginTop = `${marginTop}px`;
    }
  }

  /**
   * Sets up event listeners for page navigation and window resize events.
   * Ensures the sticky header behaves correctly after page transitions
   * and when the window is resized.
   * @returns {void}
   */
  setupEventListeners() {
    // Handle window resizes events to recalculate margins for responsive behavior
    window.addEventListener("resize", () => {
      this.fixMenuBarContainerMargin();
    });
  }

  /**
   * Sets up the scroll event handler that manages the sticky header visibility
   * based on a scroll direction. Only initializes if the sticky header element exists.
   * @returns {void}
   */
  setupScrollHandler() {
    // Attach scroll event listener for sticky header show/hide behavior
    document.addEventListener("scroll", () => {
      this.handleScroll();
    });
  }

  /**
   * Handles scroll events to show or hide the sticky header based on scroll direction.
   * The header is shown when scrolling up or near the top of the page,
   * and hidden when scrolling down to maximize content visibility.
   *
   * Uses a scroll threshold of 5 pixels to prevent excessive toggling
   * from minor scroll movements.
   * @returns {void}
   */
  handleScroll() {
    // Continuously adjust menu bar margin to handle dynamic content changes
    this.fixMenuBarContainerMargin();

    // Check if the main bar element is visible (has offsetParent when visible)
    const header = document.getElementById("main-bar")?.offsetParent;

    // Only proceed if header is visible and sticky header is in fixed position
    if (header && window.getComputedStyle(this.element).position === "fixed") {
      const currentScroll = window.scrollY;
      const goingDown = this.prevScroll > currentScroll;
      const change = Math.abs(this.prevScroll - currentScroll);

      // Apply scroll threshold to prevent excessive header toggling
      if (change > 5) {
        // Show header when scrolling up or when near the top of the page
        if (goingDown || currentScroll < this.element.offsetHeight) {
          this.element.style.top = "0";
        } else {
          // Hide header when scrolling down by moving it above the viewport
          this.element.style.top = `-${this.element.offsetHeight}px`;
        }

        // Update previous scroll position for next comparison
        this.prevScroll = currentScroll;
      }
    }
  }
}
