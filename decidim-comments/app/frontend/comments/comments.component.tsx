import { filter }           from "graphql-anywhere";
import gql                  from "graphql-tag";
import * as React           from "react";
import { graphql }          from "react-apollo";

import Application          from "../application/application.component";

import AddCommentForm       from "./add_comment_form.component";
import CommentOrderSelector from "./comment_order_selector.component";
import CommentThread        from "./comment_thread.component";

const commentsQuery                     = require("./comments.query.graphql");
const addCommentFormSessionFragment     = require("./add_comment_form_session.fragment.graphql");
const addCommentFormCommentableFragment = require("./add_comment_form_commentable.fragment.graphql");
const commentThreadFragment             = require("./comment_thread.fragment.graphql");
const commentFragment                   = require("./comment.fragment.graphql");
const commentDataFragment               = require("./comment_data.fragment.graphql");
const upVoteFragment                    = require("./up_vote.fragment.graphql");
const downVoteFragment                  = require("./down_vote.fragment.graphql");

import {
  GetCommentsQuery,
  GetCommentsQueryVariables,
} from "../support/schema";

const { I18n } = require("react-i18nify");

interface CommentsProps extends GetCommentsQuery {
  loading?: boolean;
  orderBy: string;
  reorderComments: (orderBy: string) => void;
};

/**
 * The core class of the Decidim Comments engine.
 * It renders a collection of comments given a commentable id and type.
 * @global
 * @class
 * @augments Component
 */
export class Comments extends React.Component<CommentsProps, undefined> {
  public static defaultProps: any = {
    loading: false,
    session: null,
    commentable: {
      comments: [],
    },
  };

  public render() {
    const { commentable: { comments }, reorderComments, orderBy, loading } = this.props;
    let commentClasses = "comments";
    let commentHeader = I18n.t("components.comments.title", { count: comments.length });

    if (loading) {
      commentClasses += " loading-comments";
      commentHeader = I18n.t("components.comments.loading");
    }

    return (
      <div className="columns large-9" id="comments">
        <section className={commentClasses}>
          <div className="row collapse order-by">
            <h2 className="order-by__text section-heading">
              {commentHeader}
            </h2>
            <CommentOrderSelector
              reorderComments={reorderComments}
              defaultOrderBy={orderBy}
            />
          </div>
          {this._renderBlockedCommentsWarning()}
          {this._renderCommentThreads()}
          {this._renderAddCommentForm()}
        </section>
      </div>
    );
  }

  /**
   * Renders a warning message if the commentable doesn't accept new comments.
   * @private
   * @returns {Void|DOMElement} - A warning message or nothing.
   */
  private _renderBlockedCommentsWarning() {
    const { commentable: { acceptsNewComments } } = this.props;

    if (!acceptsNewComments) {
      return (
        <div className="callout warning">
          <p>{I18n.t("components.comments.blocked_comments_warning")}</p>
        </div>
      );
    }

    return null;
  }

  /**
   * Iterates the comment's collection and render a CommentThread for each one
   * @private
   * @returns {ReactComponent[]} - A collection of CommentThread components
   */
  private _renderCommentThreads() {
    const { session, commentable: { comments, commentsHaveVotes } } = this.props;

    return comments.map((comment) => (
      <CommentThread
        key={comment.id}
        comment={comment}
        session={session}
        votable={commentsHaveVotes}
      />
    ));
  }

  /**
   * If current user is present it renders the add comment form
   * @private
   * @returns {Void|ReactComponent} - A AddCommentForm component or nothing
   */
  private _renderAddCommentForm() {
    const { session, commentable } = this.props;
    const { acceptsNewComments, commentsHaveAlignment } = commentable;

    if (acceptsNewComments) {
      return (
        <AddCommentForm
          session={session}
          commentable={commentable}
          arguable={commentsHaveAlignment}
        />
      );
    }

    return null;
  }
}

/**
 * Wrap the Comments component with a GraphQL query and children
 * fragments.
 */

window.Comments = Comments;

const CommentsWithData: any = graphql(gql`
  ${commentsQuery}
  ${addCommentFormSessionFragment}
  ${addCommentFormCommentableFragment}
  ${commentThreadFragment}
  ${commentFragment}
  ${commentDataFragment}
  ${upVoteFragment}
  ${downVoteFragment}
`, {
  options: {
    pollInterval: 15000,
  },
  props: ({ ownProps, data: { loading, session, commentable, refetch }}) => ({
    loading,
    session,
    commentable,
    orderBy: ownProps.orderBy,
    reorderComments: (orderBy: string) => {
      return refetch({
        orderBy,
      });
    },
  }),
})(Comments);

export interface CommentsApplicationProps extends GetCommentsQueryVariables {
  locale: string;
}

/**
 * Wrap the CommentsWithData component within an Application component to
 * connect it with Apollo client and store.
 * @returns {ReactComponent} - A component wrapped within an Application component
 */
const CommentsApplication: React.SFC<CommentsApplicationProps> = ({ locale, commentableId, commentableType }) => (
  <Application locale={locale}>
    <CommentsWithData
      commentableId={commentableId}
      commentableType={commentableType}
      orderBy="older"
    />
  </Application>
);

export default CommentsApplication;
