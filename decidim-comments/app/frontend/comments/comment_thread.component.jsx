import Comment from './comment.component';

const CommentThread = () => (
  <div>
    <h6 className="comment-thread__title">
      Conversación con <a href="">Maria Garcia</a></h6>
    <div className="comment-thread">
      <Comment />
    </div>
  </div>
);

export default CommentThread;
