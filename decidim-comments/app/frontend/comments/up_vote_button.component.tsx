import gql                  from "graphql-tag";
import * as React           from "react";
import { graphql }          from "react-apollo";

import VoteButton           from "./vote_button.component";

import {
  commentDataFragment,
  commentFragment,
  downVoteFragment,
  upVoteFragment,
} from "../support/fragments";

import {
  CommentFragment,
  GetCommentsQuery,
  UpVoteFragment,
  UpVoteMutation,
} from "../support/schema";

interface UpVoteButtonProps {
  comment: UpVoteFragment;
  upVote?: () => void;
}

export const UpVoteButton: React.SFC<UpVoteButtonProps> = ({
  comment: { upVotes, upVoted, downVoted },
  upVote,
}) => {
  let selectedClass = "";

  if (upVoted) {
    selectedClass = "is-vote-selected";
  } else if (downVoted) {
     selectedClass = "is-vote-notselected";
  }

  return (
    <VoteButton
      buttonClassName="comment__votes--up"
      iconName="icon-chevron-top"
      votes={upVotes}
      voteAction={upVote}
      disabled={upVoted || downVoted}
      selectedClass={selectedClass}
    />
  );
};

const upVoteMutation = `
  mutation UpVote($id: ID!) {
    comment(id: $id) {
      upVote {
        ...Comment
      }
    }
  }
`;

const UpVoteButtonWithMutation = graphql(gql`
  ${upVoteMutation}
  ${commentFragment}
  ${commentDataFragment}
  ${upVoteFragment}
  ${downVoteFragment}
`, {
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
