import { Component, PropTypes } from 'react';
import { filter, propType }     from 'graphql-anywhere';
import gql                      from 'graphql-tag';
import { I18n }                 from 'react-i18nify';

import Comment                  from './comment.component';

import commentThreadFragment    from './comment_thread.fragment.graphql'

/**
 * Define a collection of comments. It represents a conversation with multiple users.
 * @todo It doesn't handle multiple comments yet
 */
class CommentThread extends Component {
  render() {
    const { comment, currentUser } = this.props;

    return (
      <div>
        {this._renderTitle()}
        <div className="comment-thread">
          <Comment comment={filter(Comment.fragments.comment, comment)} currentUser={currentUser} />
        </div>
      </div>
    );
  }

  /**
   * Render conversation title if comment has replies
   * @private
   * @returns {Void|DOMElement} - The conversation's title
   */
  _renderTitle() {
    const { comment: { author, replies } } = this.props;
    
    if (replies.length > 0) {
      return (
        <h6 className="comment-thread__title">
          { I18n.t("components.comment_thread.title", { authorName: author.name }) }
        </h6>
      );
    }

    return null;
  }
}

CommentThread.fragments = {
  comment: gql`
    ${commentThreadFragment}
    ${Comment.fragments.comment}
  `
};

CommentThread.propTypes = {
  currentUser: PropTypes.shape({
    name: PropTypes.string.isRequired
  }),
  comment: propType(CommentThread.fragments.comment).isRequired
};

export default CommentThread;
