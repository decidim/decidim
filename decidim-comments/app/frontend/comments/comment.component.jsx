import { Component, PropTypes } from 'react';
import { propType }             from 'graphql-anywhere';
import gql                      from 'graphql-tag';
import moment                   from 'moment';
import { I18n }                 from 'react-i18nify';
import classnames               from 'classnames';

import AddCommentForm           from './add_comment_form.component';
import UpVoteButton             from './up_vote_button.component';
import DownVoteButton           from './down_vote_button.component';

import commentFragment          from './comment.fragment.graphql';
import commentDataFragment      from './comment_data.fragment.graphql';

/**
 * A single comment component with the author info and the comment's body
 * @class
 * @augments Component
 */
class Comment extends Component {
  constructor(props) {
    super(props);

    this.state = {
      showReplyForm: false
    };
  }

  render() {
    const { comment: { id, author, body, createdAt }, articleClassName } = this.props;

    const formattedCreatedAt = ` ${moment(createdAt, "YYYY-MM-DD HH:mm:ss z").format("LLL")}`;

    return (
      <article id={`comment_${id}`} className={articleClassName}>
        <div className="comment__header">
          <div className="author-data">
            <div className="author-data__main">
              <div className="author author--inline">
                <a className="author__avatar">
                  <img src={author.avatarUrl} alt="author-avatar" />
                </a>
                <a className="author__name">{author.name}</a>
                <time dateTime={createdAt}>{formattedCreatedAt}</time>
              </div>
            </div>
          </div>
        </div>
        <div className="comment__content">
          <p>
            { this._renderAlignmentBadge() }
            { body }
          </p>
        </div>
        {this._renderReplies()}
        <div className="comment__footer">
          {this._renderReplyButton()}
          {this._renderVoteButtons()}
        </div>
        {this._renderReplyForm()}
      </article>
    );
  }

  /**
   * Render reply button if user can reply the comment
   * @private
   * @returns {Void|DOMElement} - Render the reply button or not if user can reply
   */
  _renderReplyButton() {
    const { comment: { canHaveReplies }, currentUser } = this.props;
    const { showReplyForm } = this.state;

    if (currentUser && canHaveReplies) {
      return (
        <button 
          className="comment__reply muted-link"
          aria-controls="comment1-reply"
          onClick={() => this.setState({ showReplyForm: !showReplyForm })}
        >
          { I18n.t("components.comment.reply") }
        </button>
      );
    }

    return <span>&nbsp;</span>;
  }

  /**
   * Render upVote and downVote buttons when the comment is votable
   * @private
   * @returns {Void|DOMElement} - Render the upVote and downVote buttons or not
   */
  _renderVoteButtons() {
    const { comment, votable } = this.props;

    if (votable) {
      return (
        <div className="comment__votes">
          <UpVoteButton comment={comment} />
          <DownVoteButton comment={comment} />
        </div>
      );
    }

    return <span>&nbsp;</span>;
  }

  /**
   * Render comment replies alternating the css class
   * @private
   * @returns {Void|DomElement} - A wrapper element with comment replies inside
   */
  _renderReplies() {
    const { comment: { id, replies }, currentUser, votable, articleClassName } = this.props;
    let replyArticleClassName = 'comment comment--nested';
   
    if (articleClassName === 'comment comment--nested') {
      replyArticleClassName = `${replyArticleClassName} comment--nested--alt`;
    }

    if (replies) {
      return (
        <div>
          {
            replies.map((reply) => (
              <Comment
                key={`comment_${id}_reply_${reply.id}`}
                comment={reply}
                currentUser={currentUser}
                votable={votable}
                articleClassName={replyArticleClassName}
              />
            ))
          }
        </div>
      );
    }
    
    return null;
  }

  /**
   * Render reply form based on the current component state
   * @private
   * @returns {Void|ReactElement} - Render the AddCommentForm component or not
   */
  _renderReplyForm() {
    const { currentUser, comment } = this.props;
    const { showReplyForm } = this.state;

    if (showReplyForm) {
      return (
        <AddCommentForm
          commentableId={comment.id}
          commentableType="Decidim::Comments::Comment"
          currentUser={currentUser}
          showTitle={false}
          submitButtonClassName="button small hollow"
          onCommentAdded={() => this.setState({ showReplyForm: false })}
        />
      );
    }

    return null;
  }

  /**
   * Render alignment badge if comment's alignment is 0 or -1
   * @private
   * @returns {Void|DOMElement} - The alignment's badge or not
   */
  _renderAlignmentBadge() {
    const { comment: { alignment } } = this.props;
    const spanClassName = classnames('label', {
      success: alignment === 1,
      alert: alignment === -1
    });

    let label = '';
    
    if (alignment === 1) {
      label = I18n.t('components.comment.alignment.in_favor');
    } else {
      label = I18n.t('components.comment.alignment.against');
    }

    if (alignment === 1 || alignment === -1) {
      return (
        <span>
          <span className={spanClassName}>{ label }</span>
          &nbsp;
        </span>
      );
    }

    return null;
  }
}

Comment.fragments = {
  comment: gql`
    ${commentFragment}
    ${commentDataFragment}
    ${UpVoteButton.fragments.comment}
    ${DownVoteButton.fragments.comment}
  `,
  commentData: gql`
    ${commentDataFragment}
    ${UpVoteButton.fragments.comment}
    ${DownVoteButton.fragments.comment}
  `
};

Comment.defaultProps = {
  articleClassName: 'comment'
};

Comment.propTypes = {
  comment: PropTypes.oneOfType([
    propType(Comment.fragments.comment).isRequired,
    propType(Comment.fragments.commentData).isRequired
  ]).isRequired,
  currentUser: PropTypes.shape({
    name: PropTypes.string.isRequired
  }),
  articleClassName: PropTypes.string.isRequired,
  votable: PropTypes.bool
};

export default Comment;
