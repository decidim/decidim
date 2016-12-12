import { Component, PropTypes } from 'react';
import { propType }             from 'graphql-anywhere';
import gql                      from 'graphql-tag';
import UserAvatar               from 'react-user-avatar';
import moment                   from 'moment';

import AddCommentForm           from './add_comment_form.component';

import commentFragment          from './comment.fragment.graphql';

/**
 * A single comment component with the author info and the comment's body
 */
class Comment extends Component {
  constructor(props) {
    super(props);

    this.state = {
      showReplyForm: false
    };
  }

  render() {
    const { comment: { author, body, createdAt } } = this.props;

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
          {this._renderReplyButton()}
        </div>
        {this._renderReplyForm()}
      </article>
    );
  }

  _renderReplyButton() {
    const { currentUser } = this.props;
    const { showReplyForm } = this.state;

    if (currentUser) {
      return (
        <button 
          className="comment__reply muted-link"
          aria-controls="comment1-reply"
          onClick={() => this.setState({ showReplyForm: !showReplyForm })}
        >
          Responder
        </button>
      );
    }

    return <div>&nbsp</div>;
  }

  _renderReplyForm() {
    const { showReplyForm } = this.state;

    if (showReplyForm) {
      return <AddCommentForm />;
    }

    return null;
  }
}

Comment.fragments = {
  comment: gql`
    ${commentFragment}
  `
};

Comment.propTypes = {
  comment: propType(Comment.fragments.comment).isRequired,
  currentUser: PropTypes.shape({
    name: PropTypes.string.isRequired
  })
};

export default Comment;
