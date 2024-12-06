import CommentsComponent from "src/decidim/comments/comments.component"
import { screens } from "tailwindcss/defaultTheme"

window.Decidim.CommentsComponent = CommentsComponent;

const commentsInitializer = () => {
  const isMobileScreen = () => window.innerWidth < parseInt(screens.md, 10);

  // Mount comments component
  $("[data-decidim-comments]").each((_i, el) => {
    const $el = $(el);
    let comments = $(el).data("comments");
    let wasMobileScreen = isMobileScreen();
    if (!comments) {
      comments = new CommentsComponent($el, $el.data("decidim-comments"));
    }
    comments.mountComponent();
    $(el).data("comments", comments);
    window.addEventListener("resize", () => {
      if ((wasMobileScreen && !isMobileScreen()) || (!wasMobileScreen && isMobileScreen())) {
        console.log("Resizing comments component", comments);
        wasMobileScreen = isMobileScreen();
        comments.reloadAllComments();
      }
    });
  });
}

// If no jQuery is used the Tribute feature used in comments to autocomplete
// mentions stops working
$(() => commentsInitializer());
