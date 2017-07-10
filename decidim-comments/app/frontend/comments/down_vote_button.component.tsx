import * as React from "react";
import { graphql } from "react-apollo";
import { compose, withProps } from "recompose";

import VoteButton from "./vote_button.component";

import {
  AddCommentFormSessionFragment,
  CommentFragment,
  DownVoteButtonFragment,
  DownVoteMutation,
  GetCommentsQuery,
} from "../support/schema";

export interface DownVoteButtonProps {
  session: AddCommentFormSessionFragment & {
    user: any;
  } | null;
  comment: DownVoteButtonFragment;
}

interface WithProps {
  disabled: boolean;
  userLoggedIn: boolean;
  selectedClass: string;
}

interface ApolloProps {
  downVote: () => void;
}

type EnhancedProps = DownVoteButtonProps & WithProps & ApolloProps;

export const DownVoteButton: React.SFC<EnhancedProps> = ({
  comment: { downVotes },
  downVote,
  disabled,
  userLoggedIn,
  selectedClass,
}) => (
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

const downVoteMutation = require("../mutations/down_vote.mutation.graphql");

const enhance = compose<DownVoteButtonProps, DownVoteButtonProps>(
  withProps<WithProps, DownVoteButtonProps>(
    ({ session, comment: { upVoted, downVoted } }) => ({
      userLoggedIn: session && session.user,
      disabled: upVoted || downVoted,
      selectedClass: downVoted ? "is-vote-selected" : upVoted ? "is-vote-notselected" : "",
    }),
  ),
  graphql(downVoteMutation, {
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
  }),
);

export default enhance(DownVoteButton);
