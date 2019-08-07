import * as React from "react";
import { graphql, MutationFunc } from "react-apollo";

import VoteButton from "./vote_button.component";

import {
  AddCommentFormCommentableFragment,
  AddCommentFormSessionFragment,
  CommentFragment,
  GetCommentsQuery,
  UpVoteButtonFragment,
  UpVoteMutation
} from "../support/schema";

interface UpVoteButtonProps {
  session: AddCommentFormSessionFragment & {
    user: any;
  } | null;
  comment: UpVoteButtonFragment;
  upVote?: () => void;
  rootCommentable: AddCommentFormCommentableFragment;
  orderBy: string;
}

export const UpVoteButton: React.SFC<UpVoteButtonProps> = ({
  session,
  comment: { upVotes, upVoted, downVoted },
  upVote
}) => {
  let selectedClass = "";

  if (upVoted) {
    selectedClass = "is-vote-selected";
  } else if (downVoted) {
     selectedClass = "is-vote-notselected";
  }

  const userLoggedIn = session && session.user;
  const disabled = false;

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
const getCommentsQuery = require("../queries/comments.query.graphql");

const UpVoteButtonWithMutation = graphql<UpVoteMutation, UpVoteButtonProps>(upVoteMutation, {
  props: ({ ownProps, mutate }: { ownProps: UpVoteButtonProps, mutate: MutationFunc<UpVoteMutation> }) => ({
    upVote: () => mutate({
      variables: {
        id: ownProps.comment.id
      },
      optimisticResponse: {
        __typename: "Mutation",
        comment: {
          __typename: "CommentMutation",
          upVote: {
            __typename: "Comment",
            ...ownProps.comment,
            upVotes: ownProps.comment.upVotes + (ownProps.comment.upVoted ? -1 : 1),
            upVoted: true
          }
        }
      },
      update: (store, { data }: { data: UpVoteMutation }) => {
        const variables = {
          commentableId: ownProps.rootCommentable.id,
          commentableType: ownProps.rootCommentable.type,
          orderBy: ownProps.orderBy
        };

        const commentReducer = (comment: CommentFragment): CommentFragment => {
          const replies = comment.comments || [];

          if (comment.id === ownProps.comment.id && data.comment) {
            return data.comment.upVote;
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
})(UpVoteButton);

export default UpVoteButtonWithMutation;
