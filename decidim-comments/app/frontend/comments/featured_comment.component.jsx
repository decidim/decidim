import Comment from './comment.component';

const FeaturedComment = () => (
  <section className="comments">
    <h4 className="section-heading">Comentario destacado</h4>
    <div className="comment-thread comment--pinned">
      <Comment />
    </div>
  </section>
);

export default FeaturedComment;
