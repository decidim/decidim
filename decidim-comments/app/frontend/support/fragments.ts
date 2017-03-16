export const addCommentFormCommentableFragment = `
  fragment AddCommentFormCommentable on Commentable {
    id
    type
  }
`;

export const addCommentFormSessionFragment = `
  fragment AddCommentFormSession on Session {
    verifiedUserGroups {
      id
      name
    }
  }
`;

export const commentFragment = `
  fragment Comment on Comment {
    ...CommentData
    comments {
      ...CommentData
      comments {
        ...CommentData
        comments {
          ...CommentData
        }
      }
    }
  }
`;

export const commentDataFragment = `
  fragment CommentData on Comment {
    id
    sgid
    type
    body
    createdAt
    author {
      name
      avatarUrl
    }
    hasComments
    acceptsNewComments
    alignment
    alreadyReported
    ...UpVote
    ...DownVote
  }
`;

export const commentThreadFragment = `
  fragment CommentThread on Comment {
    author {
      name
    }
    hasComments
    ...Comment
  }
`;

export const downVoteFragment = `
  fragment DownVote on Comment {
    id
    downVotes
    downVoted
    upVoted
  }
`;

export const upVoteFragment = `
  fragment UpVote on Comment {
    id
    upVotes
    upVoted
    downVoted
  }
`;
