import { PropTypes }       from 'react';
import { propType }        from 'graphql-anywhere';
import { graphql }         from 'react-apollo';
import gql                 from 'graphql-tag';

import VoteButton          from './vote_button.component';

import downVoteMutation    from './down_vote.mutation.graphql';

import commentFragment     from './comment.fragment.graphql';
import commentDataFragment from './comment_data.fragment.graphql';
import upVoteFragment      from './up_vote.fragment.graphql';
import downVoteFragment    from './down_vote.fragment.graphql';

export const DownVoteButton = ({ comment: { downVotes, upVoted, downVoted }, downVote }) => {
  let selectedClass = '';

  if (downVoted) {
    selectedClass = 'is-vote-selected';
  } else if (upVoted) {
     selectedClass = 'is-vote-notselected';
  }

  return (
    <VoteButton
      buttonClassName="comment__votes--down"
      iconName="icon-chevron-bottom"
      votes={downVotes}
      voteAction={downVote}
      disabled={upVoted || downVoted}
      selectedClass={selectedClass}
    />
  );
};

DownVoteButton.fragments = {
  comment: gql`
    ${downVoteFragment}
  `
};

DownVoteButton.propTypes = {
  comment: propType(DownVoteButton.fragments.comment).isRequired,
  downVote: PropTypes.func.isRequired
};

const DownVoteButtonWithMutation = graphql(gql`
  ${downVoteMutation}
  ${commentFragment}
  ${commentDataFragment}
  ${upVoteFragment}
  ${downVoteFragment}
`, {
  props: ({ ownProps, mutate }) => ({
    downVote: () => mutate({
      variables: {
        id: ownProps.comment.id
      },
      optimisticResponse: {
        __typename: 'Mutation',
        comment: {
          __typename: 'CommentMutation',
          downVote: {
            __typename: 'Comment',
            ...ownProps.comment,
            downVotes: ownProps.comment.downVotes + 1,
            downVoted: true
          }
        }
      },
      updateQueries: {
        GetComments: (prev, { mutationResult: { data } }) => {
          const commentReducer = (comment) => {
            const replies = comment.comments || [];

            if (comment.id === ownProps.comment.id) {
              return data.comment.downVote;
            }
            return {
              ...comment,
              comments: replies.map(commentReducer)
            };
          };

          return {
            ...prev,
            comments: prev.comments.map(commentReducer)
          }
        }
      }
    })
  })
})(DownVoteButton);

export default DownVoteButtonWithMutation;
