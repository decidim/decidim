import { filter, propType }  from 'graphql-anywhere';
import gql                   from 'graphql-tag';

import Comment               from './comment.component';

import commentThreadFragment from './comment_thread.fragment.graphql'

const CommentThread = ({ comment }) => {
  const { author } = comment;

  return (
    <div>
      <h6 className="comment-thread__title">
        { `Conversation with ${author.name}` }
      </h6>
      <div className="comment-thread">
        <Comment comment={filter(Comment.fragments.comment, comment)} />
      </div>
    </div>
  );
};

CommentThread.fragments = {
  comment: gql`
    ${commentThreadFragment}
    ${Comment.fragments.comment}
  `
};

CommentThread.propTypes = {
  comment: propType(CommentThread.fragments.comment).isRequired
};

export default CommentThread;
