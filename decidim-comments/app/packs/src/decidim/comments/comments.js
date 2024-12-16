import CommentsComponent from "src/decidim/comments/comments.component";
import { screens } from "tailwindcss/defaultTheme";

window.Decidim.CommentsComponent = CommentsComponent;

const commentsInitializer = () => {
  const smBreakpoint = parseInt(screens.md.replace("px", ""), 10);
  const isMobileScreen = () => window.matchMedia(`(max-width: ${smBreakpoint}px)`).matches;

  // Mount comments component
  $("[data-decidim-comments]").each((_i, el) => {
    const $el = $(el);
    let comments = $(el).data("comments");
    let wasMobileScreen = isMobileScreen();

    if (!comments) {
      comments = new CommentsComponent($el, $el.data("decidim-comments"));
      comments.mountComponent();
      $(el).data("comments", comments);
    }

    window.addEventListener("resize", () => {
      const isNowMobileScreen = isMobileScreen();
      if ((wasMobileScreen && !isNowMobileScreen) || (!wasMobileScreen && isNowMobileScreen)) {
        if (typeof comments.unmountComponent === "function") {
          comments.unmountComponent();
        }
        comments = new CommentsComponent($el, $el.data("decidim-comments"));
        comments.mountComponent();
        wasMobileScreen = isNowMobileScreen;
        $(el).data("comments", comments);
      }
    });
  });
};

// If no jQuery is used the Tribute feature used in comments to autocomplete
// mentions stops working
$(() => commentsInitializer());
