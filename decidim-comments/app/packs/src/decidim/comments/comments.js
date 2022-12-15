import CommentsComponent from "src/decidim/comments/comments.component"

window.Decidim.CommentsComponent = CommentsComponent;

const commentsInitializer = () => {
  // Mount comments component
  $("[data-decidim-comments]").each((_i, el) => {
    const $el = $(el);
    const comments = new CommentsComponent($el, $el.data("decidim-comments"));
    comments.mountComponent();
    $(el).data("comments", comments);
  });
}

// If no jQuery is used the Tribute feature used in comments to autocomplete
// mentions stops working
$(() => commentsInitializer());
document.addEventListener("turbo:load", () => commentsInitializer());
