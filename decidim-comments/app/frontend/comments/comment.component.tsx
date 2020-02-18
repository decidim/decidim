import * as classnames from "classnames";
import * as React from "react";

import Icon from "../application/icon.component";

import AddCommentForm from "./add_comment_form.component";
import DownVoteButton from "./down_vote_button.component";
import UpVoteButton from "./up_vote_button.component";

import {
  AddCommentFormCommentableFragment,
  AddCommentFormSessionFragment,
  CommentFragment
} from "../support/schema";

import { NetworkStatus } from "apollo-client";

const { I18n } = require("react-i18nify");

interface CommentProps {
  comment: CommentFragment;
  session: AddCommentFormSessionFragment & {
    user: any;
  } | null;
  articleClassName?: string;
  isRootComment?: boolean;
  votable?: boolean;
  rootCommentable: AddCommentFormCommentableFragment;
  orderBy: string;
}

interface CommentState {
  showReplies: boolean;
  showReplyForm: boolean;
}

interface Dict {
  [key: string]: boolean | undefined;
}

/**
 * A single comment component with the author info and the comment's body
 * @class
 * @augments Component
 */
class Comment extends React.Component<CommentProps, CommentState> {
  public static defaultProps: any = {
    articleClassName: "comment",
    isRootComment: false,
    session: null,
    votable: false
  };

  public commentNode: HTMLElement;

  constructor(props: CommentProps) {
    super(props);

    const { comment: { id } } = props;
    const isThreadHidden = !!this.getThreadsStorage()[id];

    this.state = {
      showReplies: !isThreadHidden,
      showReplyForm: false
    };
  }

  public componentDidMount() {
    const { comment: { id } } = this.props;
    const hash = document.location.hash;
    const regex = new RegExp(`#comment_${id}`);

    function scrollTo(element: Element, to: number, duration: number) {
      if (duration <= 0) {
        return;
      }
      const difference = to - element.scrollTop;
      const perTick = difference / duration * 10;

      setTimeout(() => {
        element.scrollTop = element.scrollTop + perTick;
        if (element.scrollTop === to) {
          return;
        }
        scrollTo(element, to, duration - 10);
      }, 10);
    }

    if (regex.test(hash)) {
      scrollTo(document.body, this.commentNode.offsetTop, 200);
    }

    if (window.$(document).foundation) {
      window.$(`#flagModalComment${id}`).foundation();
    }
  }

  public getNodeReference = (commentNode: HTMLElement) => this.commentNode = commentNode;

  public render(): JSX.Element {
    const { session, comment: { id, author, formattedBody, createdAt, formattedCreatedAt }, articleClassName } = this.props;
    let modalName = "loginModal";

    if (session && session.user) {
      modalName = `flagModalComment${id}`;
    }

    let singleCommentUrl = `${window.location.pathname}?commentId=${id}`;

    if (window.location.search && window.location.search !== "") {
      singleCommentUrl = `${window.location.pathname}${window.location.search.replace(/commentId=\d*/gi, `commentId=${id}`)}`;
    }

    return (
      <article id={`comment_${id}`} className={articleClassName} ref={this.getNodeReference}>
        <div className="comment__header">
          <div className="author-data">
            <div className="author-data__main">
              {this._renderAuthorReference()}
              <span><time dateTime={createdAt} title={createdAt}>{formattedCreatedAt}</time></span>
            </div>
            <div className="author-data__extra">
              <button type="button" title={I18n.t("components.comment.report.title")} data-open={modalName}>
                <Icon name="icon-flag" iconExtraClassName="icon--small" />
              </button>
              {this._renderFlagModal()}
              <a href={singleCommentUrl} title={I18n.t("components.comment.single_comment_link_title")}>
                <Icon name="icon-link-intact" iconExtraClassName="icon--small" />
              </a>
            </div>
          </div>
        </div>
        <div className="comment__content">
          <div>
            {this._renderAlignmentBadge()}
            <div dangerouslySetInnerHTML={{ __html: formattedBody }} />
          </div>
        </div>
        <div className="comment__footer">
          <div className="comment__actions">
            {this._renderShowHideThreadButton()}
            {this._renderReplyButton()}
          </div>
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

  private getThreadsStorage = (): Dict => {
    const storage: Dict = JSON.parse(localStorage.hiddenCommentThreads || null) || {};

    return storage;
  }

  private saveThreadsStorage = (id: string, state: boolean) => {
    const storage = this.getThreadsStorage();
    storage[parseInt(id, 10)] = state;
    localStorage.hiddenCommentThreads = JSON.stringify(storage);
  }

  private toggleReplies = () => {
    const { comment: { id } } = this.props;
    const { showReplies } = this.state;
    const newState = !showReplies;

    this.saveThreadsStorage(id, !newState);
    this.setState({ showReplies: newState });
  }

  private countReplies = (comment: CommentFragment): number => {
    const { comments } = comment;

    if (!comments) {
      return 0;
    }

    return comments.length + comments.map(this.countReplies).reduce((a: number, b: number) => a + b, 0);
  }

  /**
   * Render author information as a link to author's profile
   * @private
   * @returns {DOMElement} - Render a link with the author information
   */
  private _renderAuthorReference() {
    const { comment: { author } } = this.props;

    if (author.profilePath === "") {
      return this._renderAuthor();
    }

    return <a href={author.profilePath}>{this._renderAuthor()}</a>;
  }

  /**
   * Render author information
   * @private
   * @returns {DOMElement} - Render all the author information
   */
  private _renderAuthor() {
    const { comment: { author } } = this.props;

    if (author.deleted) {
      return this._renderDeletedAuthor();
    }

    return this._renderActiveAuthor();
  }

  /**
   * Render deleted author information
   * @private
   * @returns {DOMElement} - Render all the author information
   */
  private _renderDeletedAuthor() {
    const { comment: { author } } = this.props;

    return (
      <div className="author author--inline">
        <span className="author__avatar">
          <img src={author.avatarUrl} alt="author-avatar" />
        </span>
        <span className="author__name">
          <span className="label label--small label--basic">
            {I18n.t("components.comment.deleted_user")}
          </span>
        </span>
      </div>
    );
  }

  /**
   * Render active author information
   * @private
   * @returns {DOMElement} - Render all the author information
   */
  private _renderActiveAuthor() {
    const { comment: { author } } = this.props;

    return (
      <div className="author author--inline">
        <span className="author__avatar">
          <img src={author.avatarUrl} alt="author-avatar" />
        </span>
        <span className="author__name">{author.name}</span>
        {author.badge === "" ||
          <span className="author__badge">
            <Icon name={`icon-${author.badge}`} />
          </span>
        }
        <span className="author__nickname">{author.nickname}</span>
      </div>
    );
  }

  /**
   * Render reply button if user can reply the comment
   * @private
   * @returns {Void|DOMElement} - Render the reply button or not if user can reply
   */
  private _renderReplyButton() {
    const { comment: { id, acceptsNewComments, userAllowedToComment }, session } = this.props;

    if (session && acceptsNewComments && userAllowedToComment) {
      return (
        <button
          className="comment__reply muted-link"
          aria-controls={`comment${id}-reply`}
          data-toggle={`comment${id}-reply`}
          onClick={this.toggleReplyForm}
        >
          <Icon name="icon-pencil" iconExtraClassName="icon--small" />
          &nbsp;
          {I18n.t("components.comment.reply")}
        </button >
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
    const { comment: { id, acceptsNewComments, hasComments, userAllowedToComment }, session, isRootComment } = this.props;
    const { showReplies } = this.state;

    if (session && acceptsNewComments && userAllowedToComment) {
      if (hasComments && isRootComment && showReplies) {
        return (
          <div className="comment__additionalreply">
            <button
              className="comment__reply muted-link"
              aria-controls={`comment${id}-reply`}
              data-toggle={`comment${id}-reply`}
              onClick={this.toggleReplyForm}
            >
              <Icon name="icon-pencil" iconExtraClassName="icon--small" />
              &nbsp;
              {I18n.t("components.comment.reply")}
            </button>
          </div>
        );
      }
    }
    return null;
  }

  /**
   * Render show/hide thread button if comment is top-level and has children.
   * @private
   * @returns {Void|DOMElement} - Render the reply button or not
   */
  private _renderShowHideThreadButton() {
    const { comment, isRootComment } = this.props;
    const { id, hasComments } = comment;
    const { showReplies } = this.state;

    if (hasComments && isRootComment) {
      return (
        <button
          className={`comment__reply muted-link ${showReplies ? "comment__is-open" : ""}`}
          onClick={this.toggleReplies}
        >
          <Icon name="icon-comment-square" iconExtraClassName="icon--small" />
          &nbsp;
          <span className="comment__text-is-closed">
            {I18n.t("components.comment.show_replies", { replies_count: this.countReplies(comment) })}
          </span>
          <span className="comment__text-is-open">
            {I18n.t("components.comment.hide_replies")}
          </span>
        </button>
      );
    }
    return null;
  }

  /**
   * Render upVote and downVote buttons when the comment is votable
   * @private
   * @returns {Void|DOMElement} - Render the upVote and downVote buttons or not
   */
  private _renderVoteButtons() {
    const { session, comment, votable, rootCommentable, orderBy } = this.props;
    const { comment: { userAllowedToComment } } = this.props;

    if (votable && userAllowedToComment) {
      return (
        <div className="comment__votes">
          <UpVoteButton session={session} comment={comment} rootCommentable={rootCommentable} orderBy={orderBy} />
          <DownVoteButton session={session} comment={comment} rootCommentable={rootCommentable} orderBy={orderBy} />
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
    const { comment: { id, hasComments, comments }, session, votable, articleClassName, rootCommentable, orderBy } = this.props;
    const { showReplies } = this.state;
    let replyArticleClassName = "comment comment--nested";

    if (articleClassName === "comment comment--nested") {
      replyArticleClassName = `${replyArticleClassName} comment--nested--alt`;
    }

    if (hasComments) {
      return (
        <div id={`comment-${id}-replies`} className={showReplies ? "" : "hide"}>
          {
            comments.map((reply: CommentFragment) => (
              <Comment
                key={`comment_${id}_reply_${reply.id}`}
                comment={reply}
                session={session}
                votable={votable}
                articleClassName={replyArticleClassName}
                rootCommentable={rootCommentable}
                orderBy={orderBy}
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
    const { session, comment, rootCommentable, orderBy } = this.props;
    const { showReplyForm } = this.state;
    const { comment: { userAllowedToComment } } = this.props;

    if (session && showReplyForm && userAllowedToComment) {
      return (
        <AddCommentForm
          session={session}
          commentable={comment}
          showTitle={false}
          submitButtonClassName="button small hollow"
          onCommentAdded={this.toggleReplyForm}
          autoFocus={true}
          rootCommentable={rootCommentable}
          orderBy={orderBy}
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
    const spanClassName = classnames("label alignment", {
      success: alignment === 1,
      alert: alignment === -1
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
  private _renderFlagModal() {
    const { session, comment: { id, sgid, alreadyReported, userAllowedToComment } } = this.props;
    const authenticityToken = this._getAuthenticityToken();

    const closeModal = () => {
      window.$(`#flagModalComment${id}`).foundation("close");
    };

    if (session && session.user && userAllowedToComment) {
      return (
        <div className="reveal flag-modal" id={`flagModalComment${id}`} data-reveal={true}>
          <div className="reveal__header">
            <h3 className="reveal__title">{I18n.t("components.comment.report.title")}</h3>
            <button
              className="close-button"
              aria-label={I18n.t("components.comment.report.close")}
              type="button"
              onClick={closeModal}
            >
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          {
            (() => {
              if (alreadyReported) {
                return (
                  <p key={`already-reported-comment-${id}`}>{I18n.t("components.comment.report.already_reported")}</p>
                );
              }
              return [
                <p key={`report-description-comment-${id}`}>{I18n.t("components.comment.report.description")}</p>,
                (
                  <form key={`report-form-comment-${id}`} method="post" action={`/report?sgid=${sgid}`}>
                    <input type="hidden" name="authenticity_token" value={authenticityToken} />
                    <label htmlFor={`report_comment_${id}_reason_spam`}>
                      <input type="radio" value="spam" name="report[reason]" id={`report_comment_${id}_reason_spam`} defaultChecked={true} />
                      {I18n.t("components.comment.report.reasons.spam")}
                    </label>
                    <label htmlFor={`report_comment_${id}_reason_offensive`}>
                      <input type="radio" value="offensive" name="report[reason]" id={`report_comment_${id}_reason_offensive`} />
                      {I18n.t("components.comment.report.reasons.offensive")}
                    </label>
                    <label htmlFor={`report_comment_${id}_reason_does_not_belong`}>
                      <input type="radio" value="does_not_belong" name="report[reason]" id={`report_comment_${id}_reason_does_not_belong`} />
                      {I18n.t("components.comment.report.reasons.does_not_belong", { organization_name: session.user.organizationName })}
                    </label>
                    <label htmlFor={`report_comment_${id}_details`}>
                      {I18n.t("components.comment.report.details")}
                      <textarea rows={4} name="report[details]" id={`report_comment_${id}_details`} />
                    </label>
                    <button type="submit" name="commit" className="button">{I18n.t("components.comment.report.action")}</button>
                  </form>
                )
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
  private _getAuthenticityToken() {
    return window.$('meta[name="csrf-token"]').attr("content");
  }
}

export default Comment;
