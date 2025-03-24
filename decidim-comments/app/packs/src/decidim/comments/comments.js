import CommentsComponent from "src/decidim/comments/comments.component";
import { screens } from "tailwindcss/defaultTheme";

window.Decidim.CommentsComponent = CommentsComponent;

/**
 * Debounce function to limit the rate at which a function is called.
 * It ensures that the function is not called more than once within the specified delay.
 *
 * @param {Function} func - The function to debounce.
 * @param {number} delay - The delay (in milliseconds) to wait before calling the function.
 * @returns {Function} - A debounced version of the original function.
 */
const debounce = (func, delay) => {
  let timeout = null;
  return (...args) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => func(...args), delay);
  };
};

/**
 * Initializes the CommentsComponent for a specific element.
 * If the component is not yet created for the given element, it creates and mounts it.
 *
 * @param {jQuery} $el - The jQuery-wrapped element to initialize the CommentsComponent for.
 * @returns {CommentsComponent} - The initialized CommentsComponent instance.
 */
const initializeCommentsComponent = ($el) => {
  const commentsData = $el.data("decidim-comments");
  let comments = $el.data("comments");

  if (!comments) {
    comments = new CommentsComponent($el, commentsData);
    comments.mountComponent();
    $el.data("comments", comments);
  }

  return comments;
};

/**
 * Updates the CommentsComponent for a specific element.
 * It unmounts any existing component and then re-initializes it.
 *
 * @param {jQuery} $el - The jQuery-wrapped element to update the CommentsComponent for.
 * @returns {void}
 */
const updateCommentsComponent = ($el) => {
  const existingComments = $el.data("comments");

  if (existingComments && typeof existingComments.unmountComponent === "function") {
    existingComments.unmountComponent();
  }

  const newComments = new CommentsComponent($el, $el.data("decidim-comments"));
  newComments.mountComponent();
  $el.data("comments", newComments);
};

/**
 * Main initializer for all comment elements on the page.
 * It sets up all CommentsComponent instances and listens for screen resizes to update components if necessary.
 *
 * @returns {void}
 */
const commentsInitializer = () => {
  const smBreakpoint = parseInt(screens.md.replace("px", ""), 10);
  const isMobileScreen = () => window.matchMedia(`(max-width: ${smBreakpoint}px)`).matches;
  let wasMobileScreen = isMobileScreen();
  const commentElements = $("[data-decidim-comments]");
  const commentsMap = new Map();

  // Initialize a CommentsComponent for each comment element
  commentElements.each((_i, el) => {
    const $el = $(el);
    const comments = initializeCommentsComponent($el);
    commentsMap.set($el, comments);
  });

  /**
   * Handles the window resize event.
   * It re-initializes the CommentsComponent for each comment element if the screen size has changed from mobile to desktop or vice versa.
   *
   * @returns {void}
   */
  const handleResize = debounce(() => {
    const isNowMobileScreen = isMobileScreen();
    if (wasMobileScreen !== isNowMobileScreen) {
      commentElements.each((_i, el) => {
        const $el = $(el);
        updateCommentsComponent($el);
      });
      wasMobileScreen = isNowMobileScreen;
    }
  }, 200);

  // Listen for window resize events and trigger the handler
  window.addEventListener("resize", handleResize);
};

// If no jQuery is used the Tribute feature used in comments to autocomplete mentions stops working
$(() => commentsInitializer());
