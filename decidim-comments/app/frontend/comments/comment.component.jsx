import { propType }    from 'graphql-anywhere';
import gql             from 'graphql-tag';

import commentFragment from './comment.fragment.graphql'

const Comment = ({ comment: { author, body, createdAt } }) => (
  <article className="comment">
    <div className="comment__header">
      <div className="author-data">
        <div className="author-data__main">
          <div className="author author--inline">
            <a className="author__avatar">
              <img alt="avatar" src="../../assets/images/demo-avatar.jpg" />
            </a>
            <a className="author__name">{author.name}</a>
            <time dateTime={createdAt}>{` ${createdAt}`}</time>
          </div>
        </div>
      </div>
    </div>
    <div className="comment__content">
      <p>{ body }</p>
    </div>
    <div className="comment__foter">
      &nbsp;
    </div>
  </article>
);

Comment.fragments = {
  comment: gql`
    ${commentFragment}
  `
};

Comment.propTypes = {
  comment: propType(Comment.fragments.comment).isRequired
};

export default Comment;
