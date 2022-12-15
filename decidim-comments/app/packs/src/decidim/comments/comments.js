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

document.addEventListener("DOMContentLoaded", () => commentsInitializer());
document.addEventListener("turbo:load", () => commentsInitializer());
