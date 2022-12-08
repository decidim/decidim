import CommentsComponent from "src/decidim/comments/comments.component"

window.Decidim.CommentsComponent = CommentsComponent;

const initializer = () => {
  // Mount comments component
  $("[data-decidim-comments]").each((_i, el) => {
    const $el = $(el);
    const comments = new CommentsComponent($el, $el.data("decidim-comments"));
    comments.mountComponent();
    $(el).data("comments", comments);
  });
}

initializer();

document.addEventListener("turbo:load", () => initializer());
