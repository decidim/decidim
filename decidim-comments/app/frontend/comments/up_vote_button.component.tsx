import * as React from "react";
import { graphql } from "react-apollo";

import VoteButton from "./vote_button.component";

import {
  AddCommentFormSessionFragment,
  CommentFragment,
  GetCommentsQuery,
  UpVoteButtonFragment,
  UpVoteMutation,
} from "../support/schema";

interface UpVoteButtonProps {
  session: AddCommentFormSessionFragment & {
    user: any;
  } | null;
  comment: UpVoteButtonFragment;
  upVote?: () => void;
}

export const UpVoteButton: React.SFC<UpVoteButtonProps> = ({
  session,
  comment: { upVotes, upVoted, downVoted },
  upVote,
}) => {
  let selectedClass = "";

  if (upVoted) {
    selectedClass = "is-vote-selected";
  } else if (downVoted) {
     selectedClass = "is-vote-notselected";
  }

  const userLoggedIn = session && session.user;
  const disabled = upVoted || downVoted;

  return (
    <VoteButton
      buttonClassName="comment__votes--up"
      iconName="icon-chevron-top"
      votes={upVotes}
      voteAction={upVote}
      disabled={disabled}
      selectedClass={selectedClass}
      userLoggedIn={userLoggedIn}
    />
  );
};

const upVoteMutation = require("../mutations/up_vote.mutation.graphql");

const UpVoteButtonWithMutation = graphql(upVoteMutation, {
  props: ({ ownProps, mutate }) => ({
    upVote: () => mutate({
      variables: {
        id: ownProps.comment.id,
      },
      optimisticResponse: {
        __typename: "Mutation",
        comment: {
          __typename: "CommentMutation",
          upVote: {
            __typename: "Comment",
            ...ownProps.comment,
            upVotes: ownProps.comment.upVotes + 1,
            upVoted: true,
          },
        },
      },
      updateQueries: {
        GetComments: (prev: GetCommentsQuery, { mutationResult: { data } }: { mutationResult: { data: UpVoteMutation}}) => {
          const commentReducer = (comment: CommentFragment): CommentFragment => {
            const replies = comment.comments || [];

            if (comment.id === ownProps.comment.id && data.comment) {
              return data.comment.upVote;
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
})(UpVoteButton);

export default UpVoteButtonWithMutation;
