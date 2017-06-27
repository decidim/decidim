import * as React from "react";
import { graphql } from "react-apollo";
import { compose, withProps } from "recompose";

import VoteButton from "./vote_button.component";

import {
  AddCommentFormSessionFragment,
  CommentFragment,
  GetCommentsQuery,
  UpVoteButtonFragment,
  UpVoteMutation,
} from "../support/schema";

export interface UpVoteButtonProps {
  session: AddCommentFormSessionFragment & {
    user: any;
  } | null;
  comment: UpVoteButtonFragment;
}

interface WithProps {
  disabled: boolean;
  userLoggedIn: boolean;
  selectedClass: string;
}

interface ApolloProps {
  upVote: () => void;
}

type EnhancedProps = UpVoteButtonProps & WithProps & ApolloProps;

export const UpVoteButton: React.SFC<EnhancedProps> = ({
  comment: { upVotes },
  upVote,
  disabled,
  selectedClass,
  userLoggedIn,
}) => (
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

const upVoteMutation = require("../mutations/up_vote.mutation.graphql");

const enhance = compose<UpVoteButtonProps, UpVoteButtonProps>(
  withProps<WithProps, UpVoteButtonProps>(
    ({ session, comment: { upVoted, downVoted } }) => ({
      userLoggedIn: session && session.user,
      disabled: upVoted || downVoted,
      selectedClass: upVoted ? "is-vote-selected" : downVoted ? "is-vote-notselected" : "",
    }),
  ),
  graphql(upVoteMutation, {
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
  }),
);

export default enhance(UpVoteButton);
