import * as React from "react";
import { graphql } from "react-apollo";

import VoteButton from "./vote_button.component";

import {
  AddCommentFormSessionFragment,
  CommentFragment,
  DownVoteButtonFragment,
  DownVoteMutation,
  GetCommentsQuery,
} from "../support/schema";

interface DownVoteButtonProps {
  session: AddCommentFormSessionFragment & {
    user: any;
  } | null;
  comment: DownVoteButtonFragment;
  downVote?: () => void;
}

export const DownVoteButton: React.SFC<DownVoteButtonProps> = ({
  session,
  comment: { downVotes, upVoted, downVoted },
  downVote,
}) => {
  let selectedClass = "";

  if (downVoted) {
    selectedClass = "is-vote-selected";
  } else if (upVoted) {
     selectedClass = "is-vote-notselected";
  }

  const userLoggedIn = session && session.user;
  const disabled = upVoted || downVoted;

  return (
    <VoteButton
      buttonClassName="comment__votes--down"
      iconName="icon-chevron-bottom"
      votes={downVotes}
      voteAction={downVote}
      disabled={disabled}
      selectedClass={selectedClass}
      userLoggedIn={userLoggedIn}
    />
  );
};

const downVoteMutation = require("../mutations/down_vote.mutation.graphql");

const DownVoteButtonWithMutation = graphql(downVoteMutation, {
  props: ({ ownProps, mutate }) => ({
    downVote: () => mutate({
      variables: {
        id: ownProps.comment.id,
      },
      optimisticResponse: {
        __typename: "Mutation",
        comment: {
          __typename: "CommentMutation",
          downVote: {
            __typename: "Comment",
            ...ownProps.comment,
            downVotes: ownProps.comment.downVotes + 1,
            downVoted: true,
          },
        },
      },
      updateQueries: {
        GetComments: (prev: GetCommentsQuery, { mutationResult: { data } }: { mutationResult: { data: DownVoteMutation }}) => {
          const commentReducer = (comment: CommentFragment): CommentFragment => {
            const replies = comment.comments || [];

            if (comment.id === ownProps.comment.id && data.comment) {
              return data.comment.downVote;
            }
            return {
              ...comment,
              comments: replies.map(commentReducer),
            };
          };

          return {
            ...prev,
            commentable: {
              ...prev.commentable,
              comments: prev.commentable.comments.map(commentReducer),
            },
          };
        },
      },
    }),
  }),
})(DownVoteButton);

export default DownVoteButtonWithMutation;
