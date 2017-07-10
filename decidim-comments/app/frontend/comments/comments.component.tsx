import * as React from "react";
import { graphql } from "react-apollo";
import { branch, compose, defaultProps, renderNothing, withProps } from "recompose";

import AddCommentForm, { AddCommentFormProps } from "./add_comment_form.component";
import CommentOrderSelector from "./comment_order_selector.component";
import CommentThread from "./comment_thread.component";

const { I18n } = require("react-i18nify");

export const commentsQuery = require("../queries/comments.query.graphql");

export interface CommentsProps {
  commentableId: string;
  commentableType: string;
  orderBy: string;
}

interface ApolloProps {
  loading: boolean;
  session: any;
  commentable: any;
  reorderComments: (orderBy: string) => void;
}

interface WithProps {
  commentClasses: string;
  commentHeader: string;
}

type EnhancedProps = CommentsProps & ApolloProps & WithProps;

const hideIf = branch<any>(
  ({ condition }) => condition,
  renderNothing,
);

const CommentsBlockedWarningIfCondition = hideIf(() => (
  <div className="callout warning">
    <p>{I18n.t("components.comments.blocked_comments_warning")}</p>
  </div>
));

const AddCommentFormIfCondition = hideIf(({ session, commentable }) => (
  <AddCommentForm
    session={session}
    commentable={commentable}
    arguable={commentable.commentsHaveAlignment}
  />
));

const hifeIfCommentsEmpty: any = branch(
  ({ commentable: { comments }}) => comments.length === 0,
  renderNothing,
);

const CommentsList = hifeIfCommentsEmpty(
  ({ commentable: { comments, commentsHaveVotes }, session }: any) => (
    <div className="comments-list">
      {
        comments.map((comment: any) => (
          <CommentThread
            key={comment.id}
            comment={comment}
            session={session}
            votable={commentsHaveVotes}
          />
        ))
      }
    </div>
  ),
);

const Comments: React.SFC<EnhancedProps> = ({
  orderBy,
  session,
  commentable,
  commentClasses,
  commentHeader,
  reorderComments,
}) => (
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
      <CommentsBlockedWarningIfCondition condition={commentable.acceptsNewComments} />
      <CommentsList commentable={commentable} session={session} />
      <AddCommentFormIfCondition condition={!commentable.acceptsNewComments} session={session} commentable={commentable}  />
    </section>
  </div>
);
const enhance = compose<CommentsProps, CommentsProps>(
  graphql(commentsQuery, {
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
  }),
  defaultProps({
    loading: false,
    session: null,
    commentable: {
      comments: [],
    },
  }),
  withProps<WithProps, ApolloProps>(
    ({ loading, commentable: { comments } }) => ({
      commentClasses: loading ? "comments loading-comments" : "comments",
      commentHeader: loading ? I18n.t("components.comments.loading") : I18n.t("components.comments.title", { count: comments.length }),
    }),
  ),
);

export default enhance(Comments);
