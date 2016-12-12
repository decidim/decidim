import { propType }    from 'graphql-anywhere';
import gql             from 'graphql-tag';
import UserAvatar      from 'react-user-avatar';
import moment          from 'moment';

import commentFragment from './comment.fragment.graphql'

/**
 * @returns {ReactComponent} - A single comment component with the author info and the comment's body
 */
const Comment = ({ comment: { author, body, createdAt } }) => {
  let authorInitialLetter = " ";
  const formattedCreatedAt = ` ${moment(createdAt, "YYYY-MM-DD HH:mm:ss z").format("LLL")}`;
  
  if (author.name.length > 0) {
    authorInitialLetter = author.name[0];
  }

  return (
    <article className="comment">
      <div className="comment__header">
        <div className="author-data">
          <div className="author-data__main">
            <div className="author author--inline">
              <span style={{ color: "#fff" }} className="author__avatar">
                <UserAvatar size="20" name={authorInitialLetter} />
              </span>
              <a className="author__name">{author.name}</a>
              <time dateTime={createdAt}>{formattedCreatedAt}</time>
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
};

Comment.fragments = {
  comment: gql`
    ${commentFragment}
  `
};

Comment.propTypes = {
  comment: propType(Comment.fragments.comment).isRequired
};

export default Comment;
