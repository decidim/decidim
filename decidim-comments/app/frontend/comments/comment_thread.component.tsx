import * as React            from "react";

import Comment               from "./comment.component";

import {
  AddCommentFormSessionFragment,
  CommentFragment,
} from "../support/schema";

const { I18n } = require("react-i18nify");

interface CommentThreadProps {
  comment: CommentFragment;
  session: AddCommentFormSessionFragment & {
    user: any;
  } | null;
  votable?: boolean;
}

/**
 * Define a collection of comments. It represents a conversation with multiple users.
 * @class
 * @augments Component
 * @todo It doesn't handle multiple comments yet
 */
class CommentThread extends React.Component<CommentThreadProps, undefined> {
  public static defaultProps: any = {
    session: null,
    votable: false,
  };

  public render() {
    const { comment, session, votable } = this.props;

    return (
      <div>
        {this._renderTitle()}
        <div className="comment-thread">
          <Comment
            comment={comment}
            session={session}
            votable={votable}
            isRootComment={true}
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
  private _renderTitle() {
    const { comment: { author, hasComments } } = this.props;

    if (hasComments) {
      return (
        <h6 className="comment-thread__title">
          {I18n.t("components.comment_thread.title", { authorName: author.name })}
        </h6>
      );
    }

    return null;
  }
}

export default CommentThread;
