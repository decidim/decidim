import * as React from "react";
import { graphql } from "react-apollo";

import Application from "../application/application.component";

import AddCommentForm from "./add_comment_form.component";
import CommentOrderSelector from "./comment_order_selector.component";
import CommentThread from "./comment_thread.component";

import { GetCommentsQuery, GetCommentsQueryVariables } from "../support/schema";

const { I18n, Translate } = require("react-i18nify");

import { debounce } from "ts-debounce";

interface CommentsProps extends GetCommentsQuery {
  loading?: boolean;
  orderBy: string;
  singleCommentId?: string;
  reorderComments: (orderBy: string) => void;
  fetchMoreComments: (page: number) => any;
}

/**
 * The core class of the Decidim Comments engine.
 * It renders a collection of comments given a commentable id and type.
 * @global
 * @class
 * @augments Component
 */
export class Comments extends React.Component<CommentsProps, { page: number }> {
  public static defaultProps: any = {
    loading: false,
    session: null,
    commentable: {
      comments: []
    }
  };

  public onScroll = debounce(() => {
    if (
      window.innerHeight + window.scrollY >=
      document.body.offsetHeight - 500
    ) {
      this._fetchMoreComments();
    }
  }, 100);

  constructor(props: CommentsProps) {
    super(props);

    this.state = {
      page: 1
    };
  }

  public componentDidMount() {
    document.addEventListener("scroll", () => this.onScroll());
  }

  public componentWillUnmount() {
    document.removeEventListener("scroll", () => this.onScroll());
  }

  public render() {
    const {
      commentable: { totalCommentsCount = 0 },
      singleCommentId,
      loading
    } = this.props;
    let commentClasses = "comments";
    let commentHeader = I18n.t("components.comments.title", {
      count: totalCommentsCount
    });

    if (singleCommentId && singleCommentId !== "") {
      commentHeader = I18n.t("components.comments.comment_details_title");
    }

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
            {this._renderCommentOrderSelector()}
          </div>
          {this._renderSingleCommentWarning()}
          {this._renderBlockedCommentsForUserWarning()}
          {this._renderBlockedCommentsWarning()}
          {this._renderAddCommentForm()}
          {this._renderCommentThreads()}
        </section>
      </div>
    );
  }

  private _fetchMoreComments() {
    const { fetchMoreComments, commentable } = this.props;
    const { totalPages } = commentable;
    const { page } = this.state;

    if (page < totalPages) {
      fetchMoreComments(page);
      this.setState({
        page: page + 1
      });
    }
  }

  /**
   * Renders warning message when viewing a single comment.
   * @private
   * @returns {Void|DOMElement} - A warning message or nothing.
   */
  private _renderSingleCommentWarning() {
    const { singleCommentId, reorderComments, orderBy } = this.props;

    if (singleCommentId && singleCommentId !== "") {
      const newUrl = `${window.location.pathname}${window.location.search.replace(`commentId=${singleCommentId}`, "")}`;

      return (
        <div className="callout secondary">
          <h5>{I18n.t("components.comments.single_comment_warning_title")}</h5>
          <p>
            <Translate
              value="components.comments.single_comment_warning"
              url={newUrl}
              dangerousHTML={true}
            />
          </p>
        </div>
      );
    }

    return null;
  }

  /**
   * Renders an order selector.
   * @private
   * @returns {Void|DOMElement} - A warning message or nothing.
   */
  private _renderCommentOrderSelector() {
    const { singleCommentId, reorderComments, orderBy } = this.props;

    if (singleCommentId && singleCommentId !== "") {
      return null;
    }

    return (
      <CommentOrderSelector
        reorderComments={reorderComments}
        defaultOrderBy={orderBy}
      />
    );
  }

  /**
   * Renders a warning message if the commentable doesn't accept new comments.
   * @private
   * @returns {Void|DOMElement} - A warning message or nothing.
   */
  private _renderBlockedCommentsWarning() {
    const {
      commentable: { acceptsNewComments, userAllowedToComment }
    } = this.props;

    if (!acceptsNewComments && !userAllowedToComment) {
      return (
        <div className="callout warning">
          <p>{I18n.t("components.comments.blocked_comments_warning")}</p>
        </div>
      );
    }

    return null;
  }

  /**
   * Renders a warning message if the participatory_space is  private and users
   * don't have permissions.
   * @private
   * @returns {Void|DOMElement} - A warning message or nothing.
   */
  private _renderBlockedCommentsForUserWarning() {
    const {
      commentable: { acceptsNewComments, userAllowedToComment }
    } = this.props;

    if (acceptsNewComments) {
      if (!userAllowedToComment) {
        return (
          <div className="callout warning">
            <p>
              {I18n.t("components.comments.blocked_comments_for_user_warning")}
            </p>
          </div>
        );
      }
    }

    return null;
  }

  /**
   * Iterates the comment's collection and render a CommentThread for each one
   * @private
   * @returns {ReactComponent[]} - A collection of CommentThread components
   */
  private _renderCommentThreads() {
    const { session, commentable, orderBy, singleCommentId } = this.props;
    const { comments, commentsHaveVotes } = commentable;

    return comments.map(comment => (
      <CommentThread
        key={comment.id}
        comment={comment}
        session={session}
        votable={commentsHaveVotes}
        rootCommentable={commentable}
        singleCommentId={singleCommentId}
        orderBy={orderBy}
      />
    ));
  }

  /**
   * If current user is present it renders the add comment form
   * @private
   * @returns {Void|ReactComponent} - A AddCommentForm component or nothing
   */
  private _renderAddCommentForm() {
    const { session, commentable, orderBy, singleCommentId } = this.props;
    const { acceptsNewComments, commentsHaveAlignment, userAllowedToComment } = commentable;

    if (singleCommentId && singleCommentId !== "") {
      return null;
    }

    if (acceptsNewComments && userAllowedToComment) {
      return (
        <AddCommentForm
          session={session}
          commentable={commentable}
          arguable={commentsHaveAlignment}
          rootCommentable={commentable}
          orderBy={orderBy}
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

export const commentsQuery = require("../queries/comments.query.graphql");

const CommentsWithData: any = graphql<GetCommentsQuery, CommentsProps>(
  commentsQuery,
  {
    props: ({ ownProps, data }) => {
      if (data) {
        const { loading, session, commentable, refetch, fetchMore } = data;

        return {
          loading,
          session,
          commentable,
          orderBy: ownProps.orderBy,
          singleCommentId: ownProps.singleCommentId,
          reorderComments: (orderBy: string) => {
            return refetch({
              orderBy
            });
          },
          fetchMoreComments: (page: number) => {
            return fetchMore({
              variables: {
                page: page + 1
              },
              updateQuery: (prev, { fetchMoreResult }) => {
                if (!fetchMoreResult) {
                  return prev;
                }
                return {
                  ...prev,
                  commentable: {
                    ...prev.commentable,
                    comments: [
                      ...prev.commentable.comments,
                      ...fetchMoreResult.commentable.comments
                    ]
                  }
                };
              }
            });
          }
        };
      }
    }
  }
)(Comments);

export interface CommentsApplicationProps extends GetCommentsQueryVariables {
  singleCommentId: string;
  locale: string;
}

/**
 * Wrap the CommentsWithData component within an Application component to
 * connect it with Apollo client and store.
 * @returns {ReactComponent} - A component wrapped within an Application component
 */
const CommentsApplication: React.SFC<CommentsApplicationProps> = ({
  locale,
  commentableId,
  commentableType,
  singleCommentId
}) => (
    <Application locale={locale}>
      <CommentsWithData
        commentableId={commentableId}
        commentableType={commentableType}
        orderBy="older"
        singleCommentId={singleCommentId}
      />
    </Application>
  );

export default CommentsApplication;
