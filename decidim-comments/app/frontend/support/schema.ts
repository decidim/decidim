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
  commentable: {
    addComment: CommentThreadFragment & CommentFragment & CommentDataFragment & UpVoteFragment & DownVoteFragment,
  } | null;
}

export interface DownVoteMutationVariables {
  id: string;
}

export interface DownVoteMutation {
  comment: {
    downVote: CommentFragment & CommentDataFragment & UpVoteFragment & DownVoteFragment,
  } | null;
}

export interface UpVoteMutationVariables {
  id: string;
}

export interface UpVoteMutation {
  comment: {
    upVote: CommentFragment & CommentDataFragment & UpVoteFragment & DownVoteFragment,
  } | null;
}

export interface GetCommentsQueryVariables {
  commentableId: string;
  commentableType: string;
  orderBy: string | null;
}

export interface GetCommentsQuery {
  session: AddCommentFormSessionFragment & {
    user: {
      name: string,
      avatarUrl: string,
      organizationName: string,
    } | null,
  } | null;
  commentable: AddCommentFormCommentableFragment & {
    acceptsNewComments: boolean,
    commentsHaveAlignment: boolean,
    commentsHaveVotes: boolean,
    comments: Array< CommentThreadFragment & CommentFragment & CommentDataFragment & UpVoteFragment & DownVoteFragment & {
      id: string,
    } >,
  };
}

export interface AddCommentFormCommentableFragment {
  id: string;
  type: string;
}

export interface AddCommentFormSessionFragment {
  verifiedUserGroups: Array< {
    id: string,
    name: string,
  } >;
}

export interface CommentDataFragment extends UpVoteFragment, DownVoteFragment {
  id: string;
  sgid: string;
  type: string;
  body: string;
  createdAt: string;
  author: {
    name: string,
    avatarUrl: string,
  };
  hasComments: boolean;
  acceptsNewComments: boolean;
  alignment: number | null;
  alreadyReported: boolean;
}

export interface CommentThreadFragment extends CommentFragment, CommentDataFragment, UpVoteFragment, DownVoteFragment {
  author: {
    name: string,
    avatarUrl: string
  };
  hasComments: boolean;
}

export interface CommentFragment extends CommentDataFragment, UpVoteFragment, DownVoteFragment {
  comments: Array< CommentDataFragment & UpVoteFragment & DownVoteFragment & {
    comments: Array< CommentDataFragment & UpVoteFragment & DownVoteFragment & {
      comments: Array<CommentDataFragment & UpVoteFragment & DownVoteFragment>,
    } >,
  } >;
}

export interface DownVoteFragment {
  id: string;
  downVotes: number;
  downVoted: boolean;
  upVoted: boolean;
}

export interface UpVoteFragment {
  id: string;
  upVotes: number;
  upVoted: boolean;
  downVoted: boolean;
}
/* tslint:enable */
