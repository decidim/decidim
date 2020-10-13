import * as React from "react";
import { graphql, MutationFunc } from "react-apollo";

const PropTypes = require("prop-types");

import VoteButton from "./vote_button.component";

const { I18n } = require("react-i18nify");

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
  upVote?: (context: any) => void;
  rootCommentable: AddCommentFormCommentableFragment;
  orderBy: string;
}

export const UpVoteButton: React.SFC<UpVoteButtonProps> = (
  {
    session,
    comment: { upVotes, upVoted, downVoted },
    upVote
  },
  context) => {
  let selectedClass = "";

  if (upVoted) {
    selectedClass = "is-vote-selected";
  } else if (downVoted) {
     selectedClass = "is-vote-notselected";
  }

  const userLoggedIn = session && session.user;
  const disabled = false;
  const voteAction = () => upVote && upVote(context);

  return (
    <VoteButton
      buttonClassName="comment__votes--up"
      iconName="icon-chevron-top"
      text={I18n.t("components.up_vote_button.text")}
      votes={upVotes}
      voteAction={voteAction}
      disabled={disabled}
      selectedClass={selectedClass}
      userLoggedIn={userLoggedIn}
    />
  );
};

UpVoteButton.contextTypes = {
  locale: PropTypes.string,
  toggleTranslations: PropTypes.bool
};

const upVoteMutation = require("../mutations/up_vote.mutation.graphql");
const getCommentsQuery = require("../queries/comments.query.graphql");

const UpVoteButtonWithMutation = graphql<UpVoteMutation, UpVoteButtonProps>(upVoteMutation, {
  props: ({ ownProps, mutate }: { ownProps: UpVoteButtonProps, mutate: MutationFunc<UpVoteMutation> }) => ({
    upVote: ({ locale, toggleTranslations }: any) => mutate({
      variables: {
        locale,
        toggleTranslations,
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
