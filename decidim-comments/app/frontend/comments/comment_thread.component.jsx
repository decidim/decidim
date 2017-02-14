import { Component, PropTypes } from 'react';
import { filter, propType }     from 'graphql-anywhere';
import gql                      from 'graphql-tag';
import { I18n }                 from 'react-i18nify';

import Comment                  from './comment.component';

import commentThreadFragment    from './comment_thread.fragment.graphql'

/**
 * Define a collection of comments. It represents a conversation with multiple users.
 * @class
 * @augments Component
 * @todo It doesn't handle multiple comments yet
 */
class CommentThread extends Component {
  render() {
    const { comment, session, votable } = this.props;

    return (
      <div>
        {this._renderTitle()}
        <div className="comment-thread">
          <Comment
            comment={filter(Comment.fragments.comment, comment)}
            session={session}
            votable={votable}
            isRootComment
          />
        </div>
      </div>
    );
  }

  /**
   * Render conversation title if comment has commments
   * @private
   * @returns {Void|DOMElement} - The conversation's title
   */
  _renderTitle() {
    const { comment: { author, hasComments } } = this.props;

    if (hasComments) {
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
  session: PropTypes.shape({
    user: PropTypes.any.isRequired
  }),
  comment: propType(CommentThread.fragments.comment).isRequired,
  votable: PropTypes.bool
};

CommentThread.defaultProps = {
  session: null,
  votable: false
};

export default CommentThread;
