//  This file was automatically generated and should not be edited.
/* tslint:disable */

export interface AddCommentMutationVariables {
  commentableId: string;
  commentableType: string;
  body: string;
  alignment: number | null;
  userGroupId: string | null;
}

export interface AddCommentMutation {
  // A commentable
  commentable: {
    // Add a new comment to a commentable
    addComment: CommentThreadFragment & CommentFragment & CommentDataFragment & UpVoteButtonFragment & DownVoteButtonFragment,
  } | null;
}

export interface DownVoteMutationVariables {
  id: string;
}

export interface DownVoteMutation {
  // A comment
  comment: {
    downVote: CommentFragment & CommentDataFragment & UpVoteButtonFragment & DownVoteButtonFragment,
  } | null;
}

export interface UpVoteMutationVariables {
  id: string;
}

export interface UpVoteMutation {
  // A comment
  comment: {
    upVote: CommentFragment & CommentDataFragment & UpVoteButtonFragment & DownVoteButtonFragment,
  } | null;
}

export interface GetCommentsQueryVariables {
  commentableId: string;
  commentableType: string;
  orderBy: string | null;
}

export interface GetCommentsQuery {
  // Return's information about the logged in user
  session: AddCommentFormSessionFragment & {
    // The current user
    user: {
      // The user's name
      name: string,
      // The user's avatar url
      avatarUrl: string,
      // The user's organization name
      organizationName: string,
    } | null,
  } | null;
  commentable: AddCommentFormCommentableFragment & {
    // Wether the object can have new comments or not
    acceptsNewComments: boolean,
    // Wether the object comments have alignment or not
    commentsHaveAlignment: boolean,
    // Wether the object comments have votes or not
    commentsHaveVotes: boolean,
    comments: Array< CommentThreadFragment & CommentFragment & CommentDataFragment & UpVoteButtonFragment & DownVoteButtonFragment & {
      // The Comment's unique ID
      id: string,
    } >,
  };
}

export interface AddCommentFormCommentableFragment {
  // The commentable's ID
  id: string;
  // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
  type: string;
}

export interface AddCommentFormSessionFragment {
  // The current user verified user groups
  verifiedUserGroups: Array< {
    // The user group's id
    id: string,
    // The user group's name
    name: string,
  } >;
}

export interface CommentFragment extends CommentDataFragment, UpVoteButtonFragment, DownVoteButtonFragment {
  comments: Array< CommentDataFragment & UpVoteButtonFragment & DownVoteButtonFragment & {
    comments: Array< CommentDataFragment & UpVoteButtonFragment & DownVoteButtonFragment & {
      comments: Array<CommentDataFragment & UpVoteButtonFragment & DownVoteButtonFragment>,
    } >,
  } >;
}

export interface CommentDataFragment extends UpVoteButtonFragment, DownVoteButtonFragment {
  // The Comment's unique ID
  id: string;
  // The Comment's signed global id
  sgid: string;
  // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
  type: string;
  // The comment message
  body: string;
  // The creation date of the comment
  createdAt: string;
  // The comment's author
  author: {
    // The author's name
    name: string,
    // The author's avatar url
    avatarUrl: string,
    // Wheter the author's account has been deleted or not
    deleted: boolean,
  };
  // Check if the commentable has comments
  hasComments: boolean;
  // Wether the object can have new comments or not
  acceptsNewComments: boolean;
  // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
  alignment: number | null;
  // Check if the current user has reported the comment
  alreadyReported: boolean;
}

export interface CommentThreadFragment extends CommentFragment, CommentDataFragment, UpVoteButtonFragment, DownVoteButtonFragment {
  // Check if the commentable has comments
  hasComments: boolean;
}

export interface DownVoteButtonFragment {
  // The Comment's unique ID
  id: string;
  // The number of comment's downVotes
  downVotes: number;
  // Check if the current user has downvoted the comment
  downVoted: boolean;
  // Check if the current user has upvoted the comment
  upVoted: boolean;
}

export interface UpVoteButtonFragment {
  // The Comment's unique ID
  id: string;
  // The number of comment's upVotes
  upVotes: number;
  // Check if the current user has upvoted the comment
  upVoted: boolean;
  // Check if the current user has downvoted the comment
  downVoted: boolean;
}
/* tslint:enable */
