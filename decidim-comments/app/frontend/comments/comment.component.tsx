import * as classnames     from "classnames";
import { propType }        from "graphql-anywhere";
import gql                 from "graphql-tag";
import * as moment         from "moment";
import * as React          from "react";

import Icon from '../application/icon.component';

import AddCommentForm      from "./add_comment_form.component";
import DownVoteButton      from "./down_vote_button.component";
import UpVoteButton        from "./up_vote_button.component";

import {
  AddCommentFormSessionFragment,
  CommentDataFragment,
  CommentFragment,
} from "../support/schema";

const { I18n } = require("react-i18nify");

interface CommentProps {
  comment: CommentFragment;
  session: AddCommentFormSessionFragment & {
    user: any;
  } | null;
  articleClassName?: string;
  isRootComment?: boolean;
  votable?: boolean;
}

interface CommentState {
  showReplyForm: boolean;
}

/**
 * A single comment component with the author info and the comment's body
 * @class
 * @augments Component
 */
class Comment extends React.Component<CommentProps, CommentState> {
  private static defaultProps: any = {
    articleClassName: "comment",
    isRootComment: false,
    session: null,
    votable: false,
  };

  constructor(props: CommentProps) {
    super(props);

    this.state = {
      showReplyForm: false,
    };
  }

  componentDidMount() {
    if ($(document).foundation) {
      const { comment: { id } } = this.props;
      $(`#flagModalComment${id}`).foundation();
    }
  }

  public render(): JSX.Element {
    const { session, comment: { id, author, body, createdAt }, articleClassName } = this.props;
    const formattedCreatedAt = ` ${moment(createdAt).format("LLL")}`;
    let modalName = 'loginModal';

    if (session && session.user) {
      modalName = `flagModalComment${id}`;
    }

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
            <div className="author-data__extra">
              <button type="button" title={ I18n.t("components.comment.report.title") } data-open={modalName}>
                <Icon name="icon-flag" iconExtraClassName="icon--small"></Icon>
              </button>
              {this._renderFlagModal()}
            </div>
          </div>
        </div>
        <div className="comment__content">
          <p>
            {this._renderAlignmentBadge()}
            {body}
          </p>
        </div>
        <div className="comment__footer">
          {this._renderReplyButton()}
          {this._renderVoteButtons()}
        </div>
        {this._renderReplies()}
        {this._renderAdditionalReplyButton()}
        {this._renderReplyForm()}
      </article>
    );
  }

  private toggleReplyForm = () => {
    const { showReplyForm } = this.state;
    this.setState({ showReplyForm: !showReplyForm });
  }

  /**
   * Render reply button if user can reply the comment
   * @private
   * @returns {Void|DOMElement} - Render the reply button or not if user can reply
   */
  private _renderReplyButton() {
    const { comment: { acceptsNewComments }, session } = this.props;
    const { showReplyForm } = this.state;

    if (session && acceptsNewComments) {
      return (
        <button
          className="comment__reply muted-link"
          aria-controls="comment1-reply"
          onClick={this.toggleReplyForm}
        >
          {I18n.t("components.comment.reply")}
        </button>
      );
    }

    return <span>&nbsp;</span>;
  }

  /**
   * Render additional reply button if user can reply the comment at the bottom of a conversation
   * @private
   * @returns {Void|DOMElement} - Render the reply button or not if user can reply
   */
  private _renderAdditionalReplyButton() {
    const { comment: { acceptsNewComments, hasComments }, session, isRootComment } = this.props;
    const { showReplyForm } = this.state;

    if (session && acceptsNewComments) {
      if (hasComments && isRootComment) {
        return (
          <div className="comment__additionalreply">
            <button
              className="comment__reply muted-link"
              aria-controls="comment1-reply"
              onClick={this.toggleReplyForm}
            >
              {I18n.t("components.comment.reply")}
            </button>
          </div>
        );
      }
    }
    return null;
  }

  /**
   * Render upVote and downVote buttons when the comment is votable
   * @private
   * @returns {Void|DOMElement} - Render the upVote and downVote buttons or not
   */
  private _renderVoteButtons() {
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
   * Render comment's comments alternating the css class
   * @private
   * @returns {Void|DomElement} - A wrapper element with comment's comments inside
   */
  private _renderReplies() {
    const { comment: { id, hasComments, comments }, session, votable, articleClassName } = this.props;
    let replyArticleClassName = "comment comment--nested";

    if (articleClassName === "comment comment--nested") {
      replyArticleClassName = `${replyArticleClassName} comment--nested--alt`;
    }

    if (hasComments) {
      return (
        <div>
          {
            comments.map((reply: CommentFragment) => (
              <Comment
                key={`comment_${id}_reply_${reply.id}`}
                comment={reply}
                session={session}
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
  private _renderReplyForm() {
    const { session, comment } = this.props;
    const { showReplyForm } = this.state;

    if (session && showReplyForm) {
      return (
        <AddCommentForm
          session={session}
          commentable={comment}
          showTitle={false}
          submitButtonClassName="button small hollow"
          onCommentAdded={this.toggleReplyForm}
          autoFocus={true}
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
  private _renderAlignmentBadge() {
    const { comment: { alignment } } = this.props;
    const spanClassName = classnames("label", {
      success: alignment === 1,
      alert: alignment === -1,
    });

    let label = "";

    if (alignment === 1) {
      label = I18n.t("components.comment.alignment.in_favor");
    } else {
      label = I18n.t("components.comment.alignment.against");
    }

    if (alignment === 1 || alignment === -1) {
      return (
        <span>
          <span className={spanClassName}>{label}</span>
          &nbsp;
        </span>
      );
    }

    return null;
  }

  /**
   * Render a modal to report the comment.
   * @private
   * @return {Void|DOMElement} - The comment's report modal or not.
   */
  _renderFlagModal() {
    const { session, comment: { id, sgid, alreadyReported } } = this.props;
    const authenticityToken = this._getAuthenticityToken();

    if (session && session.user) {
      return (
        <div className="reveal flag-modal" id={`flagModalComment${id}`} data-reveal>
          <div className="reveal__header">
            <h3 className="reveal__title">{ I18n.t("components.comment.report.title") }</h3>
            <button
              className="close-button"
              aria-label={ I18n.t("components.comment.report.close") }
              type="button"
              onClick={() => $(`#flagModalComment${id}`).foundation('close')}>
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          {
            (() => {
              if (alreadyReported) {
                return (
                  <p key={`already-reported-comment-${id}`}>{ I18n.t("components.comment.report.already_reported") }</p>
                );
              }
              return [
                <p key={`report-description-comment-${id}`}>{ I18n.t("components.comment.report.description") }</p>,
                <form key={`report-form-comment-${id}`} method="post" action={`/report?sgid=${sgid}`}>
                  <input type="hidden" name="authenticity_token" value={authenticityToken} />
                  <label htmlFor={`report_comment_${id}_reason_spam`}>
                    <input type="radio" value="spam" name="report[reason]" id={`report_comment_${id}_reason_spam`} defaultChecked />
                    { I18n.t("components.comment.report.reasons.spam") }
                  </label>
                  <label htmlFor={`report_comment_${id}_reason_offensive`}>
                    <input type="radio" value="offensive" name="report[reason]" id={`report_comment_${id}_reason_offensive`} />
                    { I18n.t("components.comment.report.reasons.offensive") }
                  </label>
                  <label htmlFor={`report_comment_${id}_reason_does_not_belong`}>
                    <input type="radio" value="does_not_belong" name="report[reason]" id={`report_comment_${id}_reason_does_not_belong`} />
                    { I18n.t("components.comment.report.reasons.does_not_belong", { organization_name: session.user.organizationName }) }
                  </label>
                  <label htmlFor={`report_comment_${id}_details`}>
                    { I18n.t("components.comment.report.details") }
                    <textarea rows={4} name="report[details]" id={`report_comment_${id}_details`} />
                  </label>
                  <button type="submit" name="commit" className="button">{ I18n.t("components.comment.report.action") }</button>
                </form>
              ];
            })()
          }
        </div>
      );
    }

    return null;
  }

  /**
   * Get Rails authenticity token so we can send requests through the report forms.
   * @private
   * @return {string} - The current authenticity token.
  */
  _getAuthenticityToken() {
    return $('meta[name="csrf-token"]').attr('content');
  }
}

export default Comment;
