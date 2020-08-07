import * as React from "react";
import { graphql, MutationFunc } from "react-apollo";

const PropTypes = require("prop-types");

import VoteButton from "./vote_button.component";

import {
  AddCommentFormCommentableFragment,
  AddCommentFormSessionFragment,
  CommentFragment,
  DownVoteButtonFragment,
  DownVoteMutation,
  GetCommentsQuery
} from "../support/schema";

const { I18n } = require("react-i18nify");

interface DownVoteButtonProps {
  session: AddCommentFormSessionFragment & {
    user: any;
  } | null;
  comment: DownVoteButtonFragment;
  downVote?: (context: any) => void;
  rootCommentable: AddCommentFormCommentableFragment;
  orderBy: string;
}

export const DownVoteButton: React.SFC<DownVoteButtonProps> = (
  {
    session,
    comment: { downVotes, upVoted, downVoted },
    downVote
  },
  context) => {
  let selectedClass = "";

  if (downVoted) {
    selectedClass = "is-vote-selected";
  } else if (upVoted) {
     selectedClass = "is-vote-notselected";
  }

  const userLoggedIn = session && session.user;
  const disabled = false;
  const voteAction = () => downVote && downVote(context);

  return (
    <VoteButton
      buttonClassName="comment__votes--down"
      iconName="icon-chevron-bottom"
      text={I18n.t("components.down_vote_button.text")}
      votes={downVotes}
      voteAction={voteAction}
      disabled={disabled}
      selectedClass={selectedClass}
      userLoggedIn={userLoggedIn}
    />
  );
};

DownVoteButton.contextTypes = {
  locale: PropTypes.string,
  toggleTranslations: PropTypes.bool
};

const downVoteMutation = require("../mutations/down_vote.mutation.graphql");
const getCommentsQuery = require("../queries/comments.query.graphql");

const DownVoteButtonWithMutation = graphql<DownVoteMutation, DownVoteButtonProps>(downVoteMutation, {
  props: ({ ownProps, mutate }: { ownProps: DownVoteButtonProps, mutate: MutationFunc<DownVoteMutation> }) => ({
    downVote: ({ locale, toggleTranslations }: any) => mutate({
      variables: {
        locale,
        toggleTranslations,
        id: ownProps.comment.id
      },
      optimisticResponse: {
        __typename: "Mutation",
        comment: {
          __typename: "CommentMutation",
          downVote: {
            __typename: "Comment",
            ...ownProps.comment,
            downVotes: ownProps.comment.downVotes + (ownProps.comment.downVoted ? -1 : 1),
            downVoted: true
          }
        }
      },
      update: (store, { data }: { data: DownVoteMutation }) => {
        const variables = {
          locale,
          toggleTranslations,
          commentableId: ownProps.rootCommentable.id,
          commentableType: ownProps.rootCommentable.type,
          orderBy: ownProps.orderBy,
          singleCommentId: null
        };

        const commentReducer = (comment: CommentFragment): CommentFragment => {
          const replies = comment.comments || [];

          if (comment.id === ownProps.comment.id && data.comment) {
            return data.comment.downVote;
          }

          return {
            ...comment,
            comments: replies.map(commentReducer)
          };
        };

        const prev = store.readQuery<GetCommentsQuery>({ query: getCommentsQuery, variables });

        if (prev) {
          store.writeQuery({
            query: getCommentsQuery,
            data: {
              ...prev,
              commentable: {
                ...prev.commentable,
                comments: prev.commentable.comments.map(commentReducer)
              }
            },
            variables
          });
        }
      }
    })
  })
})(DownVoteButton);

export default DownVoteButtonWithMutation;
