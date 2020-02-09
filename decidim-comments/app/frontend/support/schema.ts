/* tslint:disable */
//  This file was automatically generated and should not be edited.

export interface addCommentMutationVariables {
  commentableId: string,
  commentableType: string,
  body: string,
  alignment?: number | null,
  userGroupId?: string | null,
};

export interface addCommentMutation {
  // A commentable
  commentable: {
    // Add a new comment to a commentable
    addComment: {
      // Check if the commentable has comments
      hasComments: boolean,
      // The Comment's unique ID
      id: string,
      // The Comment's signed global id
      sgid: string,
      // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
      type: string,
      // The comment message
      body: string,
      // The comment message ready to display (it is expected to include HTML)
      formattedBody: string,
      // The creation date of the comment
      createdAt: string,
      // The creation date of the comment in relative format
      formattedCreatedAt: string,
      // The resource author
      author: ({
        // The author's name
        name: string,
        // The author's nickname
        nickname: string,
        // The author's avatar url
        avatarUrl: string,
        // The author's profile path
        profilePath: string,
        // Whether the author's account has been deleted or not
        deleted: boolean,
        // The author's badge icon
        badge: string,
      } | {
        // The author's name
        name: string,
        // The author's nickname
        nickname: string,
        // The author's avatar url
        avatarUrl: string,
        // The author's profile path
        profilePath: string,
        // Whether the author's account has been deleted or not
        deleted: boolean,
        // The author's badge icon
        badge: string,
      }
      ),
      // Whether the object can have new comments or not
      acceptsNewComments: boolean,
      // Check if the current user can comment
      userAllowedToComment: boolean,
      // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
      alignment: number | null,
      // Check if the current user has reported the comment
      alreadyReported: boolean,
      // The number of comment's upVotes
      upVotes: number,
      // Check if the current user has upvoted the comment
      upVoted: boolean,
      // Check if the current user has downvoted the comment
      downVoted: boolean,
      // The number of comment's downVotes
      downVotes: number,
      comments: Array<{
        // The Comment's unique ID
        id: string,
        // The Comment's signed global id
        sgid: string,
        // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
        type: string,
        // The comment message
        body: string,
        // The comment message ready to display (it is expected to include HTML)
        formattedBody: string,
        // The creation date of the comment
        createdAt: string,
        // The creation date of the comment in relative format
        formattedCreatedAt: string,
        // The resource author
        author: ({
          // The author's name
          name: string,
          // The author's nickname
          nickname: string,
          // The author's avatar url
          avatarUrl: string,
          // The author's profile path
          profilePath: string,
          // Whether the author's account has been deleted or not
          deleted: boolean,
          // The author's badge icon
          badge: string,
        } | {
          // The author's name
          name: string,
          // The author's nickname
          nickname: string,
          // The author's avatar url
          avatarUrl: string,
          // The author's profile path
          profilePath: string,
          // Whether the author's account has been deleted or not
          deleted: boolean,
          // The author's badge icon
          badge: string,
        }
        ),
        // Check if the commentable has comments
        hasComments: boolean,
        // Whether the object can have new comments or not
        acceptsNewComments: boolean,
        // Check if the current user can comment
        userAllowedToComment: boolean,
        // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
        alignment: number | null,
        // Check if the current user has reported the comment
        alreadyReported: boolean,
        // The number of comment's upVotes
        upVotes: number,
        // Check if the current user has upvoted the comment
        upVoted: boolean,
        // Check if the current user has downvoted the comment
        downVoted: boolean,
        // The number of comment's downVotes
        downVotes: number,
        comments: Array<{
          // The Comment's unique ID
          id: string,
          // The Comment's signed global id
          sgid: string,
          // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
          type: string,
          // The comment message
          body: string,
          // The comment message ready to display (it is expected to include HTML)
          formattedBody: string,
          // The creation date of the comment
          createdAt: string,
          // The creation date of the comment in relative format
          formattedCreatedAt: string,
          // The resource author
          author: ({
            // The author's name
            name: string,
            // The author's nickname
            nickname: string,
            // The author's avatar url
            avatarUrl: string,
            // The author's profile path
            profilePath: string,
            // Whether the author's account has been deleted or not
            deleted: boolean,
            // The author's badge icon
            badge: string,
          } | {
            // The author's name
            name: string,
            // The author's nickname
            nickname: string,
            // The author's avatar url
            avatarUrl: string,
            // The author's profile path
            profilePath: string,
            // Whether the author's account has been deleted or not
            deleted: boolean,
            // The author's badge icon
            badge: string,
          }
          ),
          // Check if the commentable has comments
          hasComments: boolean,
          // Whether the object can have new comments or not
          acceptsNewComments: boolean,
          // Check if the current user can comment
          userAllowedToComment: boolean,
          // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
          alignment: number | null,
          // Check if the current user has reported the comment
          alreadyReported: boolean,
          // The number of comment's upVotes
          upVotes: number,
          // Check if the current user has upvoted the comment
          upVoted: boolean,
          // Check if the current user has downvoted the comment
          downVoted: boolean,
          // The number of comment's downVotes
          downVotes: number,
          comments: Array<{
            // The Comment's unique ID
            id: string,
            // The Comment's signed global id
            sgid: string,
            // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
            type: string,
            // The comment message
            body: string,
            // The comment message ready to display (it is expected to include HTML)
            formattedBody: string,
            // The creation date of the comment
            createdAt: string,
            // The creation date of the comment in relative format
            formattedCreatedAt: string,
            // The resource author
            author: ({
              // The author's name
              name: string,
              // The author's nickname
              nickname: string,
              // The author's avatar url
              avatarUrl: string,
              // The author's profile path
              profilePath: string,
              // Whether the author's account has been deleted or not
              deleted: boolean,
              // The author's badge icon
              badge: string,
            } | {
              // The author's name
              name: string,
              // The author's nickname
              nickname: string,
              // The author's avatar url
              avatarUrl: string,
              // The author's profile path
              profilePath: string,
              // Whether the author's account has been deleted or not
              deleted: boolean,
              // The author's badge icon
              badge: string,
            }
            ),
            // Check if the commentable has comments
            hasComments: boolean,
            // Whether the object can have new comments or not
            acceptsNewComments: boolean,
            // Check if the current user can comment
            userAllowedToComment: boolean,
            // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
            alignment: number | null,
            // Check if the current user has reported the comment
            alreadyReported: boolean,
            // The number of comment's upVotes
            upVotes: number,
            // Check if the current user has upvoted the comment
            upVoted: boolean,
            // Check if the current user has downvoted the comment
            downVoted: boolean,
            // The number of comment's downVotes
            downVotes: number,
          }>,
        }>,
      }>,
    } | null,
  } | null,
};

export interface DownVoteMutationVariables {
  id: string,
};

export interface DownVoteMutation {
  // A comment
  comment: {
    downVote: {
      // The Comment's unique ID
      id: string,
      // The Comment's signed global id
      sgid: string,
      // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
      type: string,
      // The comment message
      body: string,
      // The comment message ready to display (it is expected to include HTML)
      formattedBody: string,
      // The creation date of the comment
      createdAt: string,
      // The creation date of the comment in relative format
      formattedCreatedAt: string,
      // The resource author
      author: ({
        // The author's name
        name: string,
        // The author's nickname
        nickname: string,
        // The author's avatar url
        avatarUrl: string,
        // The author's profile path
        profilePath: string,
        // Whether the author's account has been deleted or not
        deleted: boolean,
        // The author's badge icon
        badge: string,
      } | {
        // The author's name
        name: string,
        // The author's nickname
        nickname: string,
        // The author's avatar url
        avatarUrl: string,
        // The author's profile path
        profilePath: string,
        // Whether the author's account has been deleted or not
        deleted: boolean,
        // The author's badge icon
        badge: string,
      }
      ),
      // Check if the commentable has comments
      hasComments: boolean,
      // Whether the object can have new comments or not
      acceptsNewComments: boolean,
      // Check if the current user can comment
      userAllowedToComment: boolean,
      // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
      alignment: number | null,
      // Check if the current user has reported the comment
      alreadyReported: boolean,
      // The number of comment's upVotes
      upVotes: number,
      // Check if the current user has upvoted the comment
      upVoted: boolean,
      // Check if the current user has downvoted the comment
      downVoted: boolean,
      // The number of comment's downVotes
      downVotes: number,
      comments: Array<{
        // The Comment's unique ID
        id: string,
        // The Comment's signed global id
        sgid: string,
        // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
        type: string,
        // The comment message
        body: string,
        // The comment message ready to display (it is expected to include HTML)
        formattedBody: string,
        // The creation date of the comment
        createdAt: string,
        // The creation date of the comment in relative format
        formattedCreatedAt: string,
        // The resource author
        author: ({
          // The author's name
          name: string,
          // The author's nickname
          nickname: string,
          // The author's avatar url
          avatarUrl: string,
          // The author's profile path
          profilePath: string,
          // Whether the author's account has been deleted or not
          deleted: boolean,
          // The author's badge icon
          badge: string,
        } | {
          // The author's name
          name: string,
          // The author's nickname
          nickname: string,
          // The author's avatar url
          avatarUrl: string,
          // The author's profile path
          profilePath: string,
          // Whether the author's account has been deleted or not
          deleted: boolean,
          // The author's badge icon
          badge: string,
        }
        ),
        // Check if the commentable has comments
        hasComments: boolean,
        // Whether the object can have new comments or not
        acceptsNewComments: boolean,
        // Check if the current user can comment
        userAllowedToComment: boolean,
        // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
        alignment: number | null,
        // Check if the current user has reported the comment
        alreadyReported: boolean,
        // The number of comment's upVotes
        upVotes: number,
        // Check if the current user has upvoted the comment
        upVoted: boolean,
        // Check if the current user has downvoted the comment
        downVoted: boolean,
        // The number of comment's downVotes
        downVotes: number,
        comments: Array<{
          // The Comment's unique ID
          id: string,
          // The Comment's signed global id
          sgid: string,
          // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
          type: string,
          // The comment message
          body: string,
          // The comment message ready to display (it is expected to include HTML)
          formattedBody: string,
          // The creation date of the comment
          createdAt: string,
          // The creation date of the comment in relative format
          formattedCreatedAt: string,
          // The resource author
          author: ({
            // The author's name
            name: string,
            // The author's nickname
            nickname: string,
            // The author's avatar url
            avatarUrl: string,
            // The author's profile path
            profilePath: string,
            // Whether the author's account has been deleted or not
            deleted: boolean,
            // The author's badge icon
            badge: string,
          } | {
            // The author's name
            name: string,
            // The author's nickname
            nickname: string,
            // The author's avatar url
            avatarUrl: string,
            // The author's profile path
            profilePath: string,
            // Whether the author's account has been deleted or not
            deleted: boolean,
            // The author's badge icon
            badge: string,
          }
          ),
          // Check if the commentable has comments
          hasComments: boolean,
          // Whether the object can have new comments or not
          acceptsNewComments: boolean,
          // Check if the current user can comment
          userAllowedToComment: boolean,
          // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
          alignment: number | null,
          // Check if the current user has reported the comment
          alreadyReported: boolean,
          // The number of comment's upVotes
          upVotes: number,
          // Check if the current user has upvoted the comment
          upVoted: boolean,
          // Check if the current user has downvoted the comment
          downVoted: boolean,
          // The number of comment's downVotes
          downVotes: number,
          comments: Array<{
            // The Comment's unique ID
            id: string,
            // The Comment's signed global id
            sgid: string,
            // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
            type: string,
            // The comment message
            body: string,
            // The comment message ready to display (it is expected to include HTML)
            formattedBody: string,
            // The creation date of the comment
            createdAt: string,
            // The creation date of the comment in relative format
            formattedCreatedAt: string,
            // The resource author
            author: ({
              // The author's name
              name: string,
              // The author's nickname
              nickname: string,
              // The author's avatar url
              avatarUrl: string,
              // The author's profile path
              profilePath: string,
              // Whether the author's account has been deleted or not
              deleted: boolean,
              // The author's badge icon
              badge: string,
            } | {
              // The author's name
              name: string,
              // The author's nickname
              nickname: string,
              // The author's avatar url
              avatarUrl: string,
              // The author's profile path
              profilePath: string,
              // Whether the author's account has been deleted or not
              deleted: boolean,
              // The author's badge icon
              badge: string,
            }
            ),
            // Check if the commentable has comments
            hasComments: boolean,
            // Whether the object can have new comments or not
            acceptsNewComments: boolean,
            // Check if the current user can comment
            userAllowedToComment: boolean,
            // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
            alignment: number | null,
            // Check if the current user has reported the comment
            alreadyReported: boolean,
            // The number of comment's upVotes
            upVotes: number,
            // Check if the current user has upvoted the comment
            upVoted: boolean,
            // Check if the current user has downvoted the comment
            downVoted: boolean,
            // The number of comment's downVotes
            downVotes: number,
          }>,
        }>,
      }>,
    },
  } | null,
};

export interface UpVoteMutationVariables {
  id: string,
};

export interface UpVoteMutation {
  // A comment
  comment: {
    upVote: {
      // The Comment's unique ID
      id: string,
      // The Comment's signed global id
      sgid: string,
      // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
      type: string,
      // The comment message
      body: string,
      // The comment message ready to display (it is expected to include HTML)
      formattedBody: string,
      // The creation date of the comment
      createdAt: string,
      // The creation date of the comment in relative format
      formattedCreatedAt: string,
      // The resource author
      author: ({
        // The author's name
        name: string,
        // The author's nickname
        nickname: string,
        // The author's avatar url
        avatarUrl: string,
        // The author's profile path
        profilePath: string,
        // Whether the author's account has been deleted or not
        deleted: boolean,
        // The author's badge icon
        badge: string,
      } | {
        // The author's name
        name: string,
        // The author's nickname
        nickname: string,
        // The author's avatar url
        avatarUrl: string,
        // The author's profile path
        profilePath: string,
        // Whether the author's account has been deleted or not
        deleted: boolean,
        // The author's badge icon
        badge: string,
      }
      ),
      // Check if the commentable has comments
      hasComments: boolean,
      // Whether the object can have new comments or not
      acceptsNewComments: boolean,
      // Check if the current user can comment
      userAllowedToComment: boolean,
      // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
      alignment: number | null,
      // Check if the current user has reported the comment
      alreadyReported: boolean,
      // The number of comment's upVotes
      upVotes: number,
      // Check if the current user has upvoted the comment
      upVoted: boolean,
      // Check if the current user has downvoted the comment
      downVoted: boolean,
      // The number of comment's downVotes
      downVotes: number,
      comments: Array<{
        // The Comment's unique ID
        id: string,
        // The Comment's signed global id
        sgid: string,
        // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
        type: string,
        // The comment message
        body: string,
        // The comment message ready to display (it is expected to include HTML)
        formattedBody: string,
        // The creation date of the comment
        createdAt: string,
        // The creation date of the comment in relative format
        formattedCreatedAt: string,
        // The resource author
        author: ({
          // The author's name
          name: string,
          // The author's nickname
          nickname: string,
          // The author's avatar url
          avatarUrl: string,
          // The author's profile path
          profilePath: string,
          // Whether the author's account has been deleted or not
          deleted: boolean,
          // The author's badge icon
          badge: string,
        } | {
          // The author's name
          name: string,
          // The author's nickname
          nickname: string,
          // The author's avatar url
          avatarUrl: string,
          // The author's profile path
          profilePath: string,
          // Whether the author's account has been deleted or not
          deleted: boolean,
          // The author's badge icon
          badge: string,
        }
        ),
        // Check if the commentable has comments
        hasComments: boolean,
        // Whether the object can have new comments or not
        acceptsNewComments: boolean,
        // Check if the current user can comment
        userAllowedToComment: boolean,
        // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
        alignment: number | null,
        // Check if the current user has reported the comment
        alreadyReported: boolean,
        // The number of comment's upVotes
        upVotes: number,
        // Check if the current user has upvoted the comment
        upVoted: boolean,
        // Check if the current user has downvoted the comment
        downVoted: boolean,
        // The number of comment's downVotes
        downVotes: number,
        comments: Array<{
          // The Comment's unique ID
          id: string,
          // The Comment's signed global id
          sgid: string,
          // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
          type: string,
          // The comment message
          body: string,
          // The comment message ready to display (it is expected to include HTML)
          formattedBody: string,
          // The creation date of the comment
          createdAt: string,
          // The creation date of the comment in relative format
          formattedCreatedAt: string,
          // The resource author
          author: ({
            // The author's name
            name: string,
            // The author's nickname
            nickname: string,
            // The author's avatar url
            avatarUrl: string,
            // The author's profile path
            profilePath: string,
            // Whether the author's account has been deleted or not
            deleted: boolean,
            // The author's badge icon
            badge: string,
          } | {
            // The author's name
            name: string,
            // The author's nickname
            nickname: string,
            // The author's avatar url
            avatarUrl: string,
            // The author's profile path
            profilePath: string,
            // Whether the author's account has been deleted or not
            deleted: boolean,
            // The author's badge icon
            badge: string,
          }
          ),
          // Check if the commentable has comments
          hasComments: boolean,
          // Whether the object can have new comments or not
          acceptsNewComments: boolean,
          // Check if the current user can comment
          userAllowedToComment: boolean,
          // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
          alignment: number | null,
          // Check if the current user has reported the comment
          alreadyReported: boolean,
          // The number of comment's upVotes
          upVotes: number,
          // Check if the current user has upvoted the comment
          upVoted: boolean,
          // Check if the current user has downvoted the comment
          downVoted: boolean,
          // The number of comment's downVotes
          downVotes: number,
          comments: Array<{
            // The Comment's unique ID
            id: string,
            // The Comment's signed global id
            sgid: string,
            // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
            type: string,
            // The comment message
            body: string,
            // The comment message ready to display (it is expected to include HTML)
            formattedBody: string,
            // The creation date of the comment
            createdAt: string,
            // The creation date of the comment in relative format
            formattedCreatedAt: string,
            // The resource author
            author: ({
              // The author's name
              name: string,
              // The author's nickname
              nickname: string,
              // The author's avatar url
              avatarUrl: string,
              // The author's profile path
              profilePath: string,
              // Whether the author's account has been deleted or not
              deleted: boolean,
              // The author's badge icon
              badge: string,
            } | {
              // The author's name
              name: string,
              // The author's nickname
              nickname: string,
              // The author's avatar url
              avatarUrl: string,
              // The author's profile path
              profilePath: string,
              // Whether the author's account has been deleted or not
              deleted: boolean,
              // The author's badge icon
              badge: string,
            }
            ),
            // Check if the commentable has comments
            hasComments: boolean,
            // Whether the object can have new comments or not
            acceptsNewComments: boolean,
            // Check if the current user can comment
            userAllowedToComment: boolean,
            // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
            alignment: number | null,
            // Check if the current user has reported the comment
            alreadyReported: boolean,
            // The number of comment's upVotes
            upVotes: number,
            // Check if the current user has upvoted the comment
            upVoted: boolean,
            // Check if the current user has downvoted the comment
            downVoted: boolean,
            // The number of comment's downVotes
            downVotes: number,
          }>,
        }>,
      }>,
    },
  } | null,
};

export interface GetCommentsQueryVariables {
  commentableId: string,
  commentableType: string,
  orderBy?: string | null,
  singleCommentId?: string | null,
};

export interface GetCommentsQuery {
  // Return's information about the logged in user
  session: {
    // The current user
    user: {
      // The user's name
      name: string,
      // The user's nickname
      nickname: string,
      // The user's avatar url
      avatarUrl: string,
      // The user's organization name
      organizationName: string,
    } | null,
    // The current user verified user groups
    verifiedUserGroups: Array<{
      // The user group's id
      id: string,
      // The user group's name
      name: string,
    }>,
  } | null,
  commentable: {
    // Whether the object can have new comments or not
    acceptsNewComments: boolean,
    // Check if the current user can comment
    userAllowedToComment: boolean,
    // Whether the object comments have alignment or not
    commentsHaveAlignment: boolean,
    // Whether the object comments have votes or not
    commentsHaveVotes: boolean,
    // The number of comments in all levels this resource holds
    totalCommentsCount: number,
    comments: Array<{
      // The Comment's unique ID
      id: string,
      // Check if the commentable has comments
      hasComments: boolean,
      // The Comment's signed global id
      sgid: string,
      // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
      type: string,
      // The comment message
      body: string,
      // The comment message ready to display (it is expected to include HTML)
      formattedBody: string,
      // The creation date of the comment
      createdAt: string,
      // The creation date of the comment in relative format
      formattedCreatedAt: string,
      // The resource author
      author: ({
        // The author's name
        name: string,
        // The author's nickname
        nickname: string,
        // The author's avatar url
        avatarUrl: string,
        // The author's profile path
        profilePath: string,
        // Whether the author's account has been deleted or not
        deleted: boolean,
        // The author's badge icon
        badge: string,
      } | {
        // The author's name
        name: string,
        // The author's nickname
        nickname: string,
        // The author's avatar url
        avatarUrl: string,
        // The author's profile path
        profilePath: string,
        // Whether the author's account has been deleted or not
        deleted: boolean,
        // The author's badge icon
        badge: string,
      }
      ),
      // Whether the object can have new comments or not
      acceptsNewComments: boolean,
      // Check if the current user can comment
      userAllowedToComment: boolean,
      // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
      alignment: number | null,
      // Check if the current user has reported the comment
      alreadyReported: boolean,
      // The number of comment's upVotes
      upVotes: number,
      // Check if the current user has upvoted the comment
      upVoted: boolean,
      // Check if the current user has downvoted the comment
      downVoted: boolean,
      // The number of comment's downVotes
      downVotes: number,
      comments: Array<{
        // The Comment's unique ID
        id: string,
        // The Comment's signed global id
        sgid: string,
        // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
        type: string,
        // The comment message
        body: string,
        // The comment message ready to display (it is expected to include HTML)
        formattedBody: string,
        // The creation date of the comment
        createdAt: string,
        // The creation date of the comment in relative format
        formattedCreatedAt: string,
        // The resource author
        author: ({
          // The author's name
          name: string,
          // The author's nickname
          nickname: string,
          // The author's avatar url
          avatarUrl: string,
          // The author's profile path
          profilePath: string,
          // Whether the author's account has been deleted or not
          deleted: boolean,
          // The author's badge icon
          badge: string,
        } | {
          // The author's name
          name: string,
          // The author's nickname
          nickname: string,
          // The author's avatar url
          avatarUrl: string,
          // The author's profile path
          profilePath: string,
          // Whether the author's account has been deleted or not
          deleted: boolean,
          // The author's badge icon
          badge: string,
        }
        ),
        // Check if the commentable has comments
        hasComments: boolean,
        // Whether the object can have new comments or not
        acceptsNewComments: boolean,
        // Check if the current user can comment
        userAllowedToComment: boolean,
        // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
        alignment: number | null,
        // Check if the current user has reported the comment
        alreadyReported: boolean,
        // The number of comment's upVotes
        upVotes: number,
        // Check if the current user has upvoted the comment
        upVoted: boolean,
        // Check if the current user has downvoted the comment
        downVoted: boolean,
        // The number of comment's downVotes
        downVotes: number,
        comments: Array<{
          // The Comment's unique ID
          id: string,
          // The Comment's signed global id
          sgid: string,
          // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
          type: string,
          // The comment message
          body: string,
          // The comment message ready to display (it is expected to include HTML)
          formattedBody: string,
          // The creation date of the comment
          createdAt: string,
          // The creation date of the comment in relative format
          formattedCreatedAt: string,
          // The resource author
          author: ({
            // The author's name
            name: string,
            // The author's nickname
            nickname: string,
            // The author's avatar url
            avatarUrl: string,
            // The author's profile path
            profilePath: string,
            // Whether the author's account has been deleted or not
            deleted: boolean,
            // The author's badge icon
            badge: string,
          } | {
            // The author's name
            name: string,
            // The author's nickname
            nickname: string,
            // The author's avatar url
            avatarUrl: string,
            // The author's profile path
            profilePath: string,
            // Whether the author's account has been deleted or not
            deleted: boolean,
            // The author's badge icon
            badge: string,
          }
          ),
          // Check if the commentable has comments
          hasComments: boolean,
          // Whether the object can have new comments or not
          acceptsNewComments: boolean,
          // Check if the current user can comment
          userAllowedToComment: boolean,
          // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
          alignment: number | null,
          // Check if the current user has reported the comment
          alreadyReported: boolean,
          // The number of comment's upVotes
          upVotes: number,
          // Check if the current user has upvoted the comment
          upVoted: boolean,
          // Check if the current user has downvoted the comment
          downVoted: boolean,
          // The number of comment's downVotes
          downVotes: number,
          comments: Array<{
            // The Comment's unique ID
            id: string,
            // The Comment's signed global id
            sgid: string,
            // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
            type: string,
            // The comment message
            body: string,
            // The comment message ready to display (it is expected to include HTML)
            formattedBody: string,
            // The creation date of the comment
            createdAt: string,
            // The creation date of the comment in relative format
            formattedCreatedAt: string,
            // The resource author
            author: ({
              // The author's name
              name: string,
              // The author's nickname
              nickname: string,
              // The author's avatar url
              avatarUrl: string,
              // The author's profile path
              profilePath: string,
              // Whether the author's account has been deleted or not
              deleted: boolean,
              // The author's badge icon
              badge: string,
            } | {
              // The author's name
              name: string,
              // The author's nickname
              nickname: string,
              // The author's avatar url
              avatarUrl: string,
              // The author's profile path
              profilePath: string,
              // Whether the author's account has been deleted or not
              deleted: boolean,
              // The author's badge icon
              badge: string,
            }
            ),
            // Check if the commentable has comments
            hasComments: boolean,
            // Whether the object can have new comments or not
            acceptsNewComments: boolean,
            // Check if the current user can comment
            userAllowedToComment: boolean,
            // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
            alignment: number | null,
            // Check if the current user has reported the comment
            alreadyReported: boolean,
            // The number of comment's upVotes
            upVotes: number,
            // Check if the current user has upvoted the comment
            upVoted: boolean,
            // Check if the current user has downvoted the comment
            downVoted: boolean,
            // The number of comment's downVotes
            downVotes: number,
          }>,
        }>,
      }>,
    }>,
    // The commentable's ID
    id: string,
    // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
    type: string,
  },
};

export interface AddCommentFormCommentableFragment {
  // The commentable's ID
  id: string,
  // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
  type: string,
};

export interface AddCommentFormSessionFragment {
  // The current user verified user groups
  verifiedUserGroups: Array<{
    // The user group's id
    id: string,
    // The user group's name
    name: string,
  }>,
};

export interface CommentFragment {
  // The Comment's unique ID
  id: string,
  // The Comment's signed global id
  sgid: string,
  // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
  type: string,
  // The comment message
  body: string,
  // The comment message ready to display (it is expected to include HTML)
  formattedBody: string,
  // The creation date of the comment
  createdAt: string,
  // The creation date of the comment in relative format
  formattedCreatedAt: string,
  // The resource author
  author: ({
    // The author's name
    name: string,
    // The author's nickname
    nickname: string,
    // The author's avatar url
    avatarUrl: string,
    // The author's profile path
    profilePath: string,
    // Whether the author's account has been deleted or not
    deleted: boolean,
    // The author's badge icon
    badge: string,
  } | {
    // The author's name
    name: string,
    // The author's nickname
    nickname: string,
    // The author's avatar url
    avatarUrl: string,
    // The author's profile path
    profilePath: string,
    // Whether the author's account has been deleted or not
    deleted: boolean,
    // The author's badge icon
    badge: string,
  }
  ),
  // Check if the commentable has comments
  hasComments: boolean,
  // Whether the object can have new comments or not
  acceptsNewComments: boolean,
  // Check if the current user can comment
  userAllowedToComment: boolean,
  // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
  alignment: number | null,
  // Check if the current user has reported the comment
  alreadyReported: boolean,
  // The number of comment's upVotes
  upVotes: number,
  // Check if the current user has upvoted the comment
  upVoted: boolean,
  // Check if the current user has downvoted the comment
  downVoted: boolean,
  // The number of comment's downVotes
  downVotes: number,
  comments: Array<{
    // The Comment's unique ID
    id: string,
    // The Comment's signed global id
    sgid: string,
    // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
    type: string,
    // The comment message
    body: string,
    // The comment message ready to display (it is expected to include HTML)
    formattedBody: string,
    // The creation date of the comment
    createdAt: string,
    // The creation date of the comment in relative format
    formattedCreatedAt: string,
    // The resource author
    author: ({
      // The author's name
      name: string,
      // The author's nickname
      nickname: string,
      // The author's avatar url
      avatarUrl: string,
      // The author's profile path
      profilePath: string,
      // Whether the author's account has been deleted or not
      deleted: boolean,
      // The author's badge icon
      badge: string,
    } | {
      // The author's name
      name: string,
      // The author's nickname
      nickname: string,
      // The author's avatar url
      avatarUrl: string,
      // The author's profile path
      profilePath: string,
      // Whether the author's account has been deleted or not
      deleted: boolean,
      // The author's badge icon
      badge: string,
    }
    ),
    // Check if the commentable has comments
    hasComments: boolean,
    // Whether the object can have new comments or not
    acceptsNewComments: boolean,
    // Check if the current user can comment
    userAllowedToComment: boolean,
    // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
    alignment: number | null,
    // Check if the current user has reported the comment
    alreadyReported: boolean,
    // The number of comment's upVotes
    upVotes: number,
    // Check if the current user has upvoted the comment
    upVoted: boolean,
    // Check if the current user has downvoted the comment
    downVoted: boolean,
    // The number of comment's downVotes
    downVotes: number,
    comments: Array<{
      // The Comment's unique ID
      id: string,
      // The Comment's signed global id
      sgid: string,
      // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
      type: string,
      // The comment message
      body: string,
      // The comment message ready to display (it is expected to include HTML)
      formattedBody: string,
      // The creation date of the comment
      createdAt: string,
      // The creation date of the comment in relative format
      formattedCreatedAt: string,
      // The resource author
      author: ({
        // The author's name
        name: string,
        // The author's nickname
        nickname: string,
        // The author's avatar url
        avatarUrl: string,
        // The author's profile path
        profilePath: string,
        // Whether the author's account has been deleted or not
        deleted: boolean,
        // The author's badge icon
        badge: string,
      } | {
        // The author's name
        name: string,
        // The author's nickname
        nickname: string,
        // The author's avatar url
        avatarUrl: string,
        // The author's profile path
        profilePath: string,
        // Whether the author's account has been deleted or not
        deleted: boolean,
        // The author's badge icon
        badge: string,
      }
      ),
      // Check if the commentable has comments
      hasComments: boolean,
      // Whether the object can have new comments or not
      acceptsNewComments: boolean,
      // Check if the current user can comment
      userAllowedToComment: boolean,
      // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
      alignment: number | null,
      // Check if the current user has reported the comment
      alreadyReported: boolean,
      // The number of comment's upVotes
      upVotes: number,
      // Check if the current user has upvoted the comment
      upVoted: boolean,
      // Check if the current user has downvoted the comment
      downVoted: boolean,
      // The number of comment's downVotes
      downVotes: number,
      comments: Array<{
        // The Comment's unique ID
        id: string,
        // The Comment's signed global id
        sgid: string,
        // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
        type: string,
        // The comment message
        body: string,
        // The comment message ready to display (it is expected to include HTML)
        formattedBody: string,
        // The creation date of the comment
        createdAt: string,
        // The creation date of the comment in relative format
        formattedCreatedAt: string,
        // The resource author
        author: ({
          // The author's name
          name: string,
          // The author's nickname
          nickname: string,
          // The author's avatar url
          avatarUrl: string,
          // The author's profile path
          profilePath: string,
          // Whether the author's account has been deleted or not
          deleted: boolean,
          // The author's badge icon
          badge: string,
        } | {
          // The author's name
          name: string,
          // The author's nickname
          nickname: string,
          // The author's avatar url
          avatarUrl: string,
          // The author's profile path
          profilePath: string,
          // Whether the author's account has been deleted or not
          deleted: boolean,
          // The author's badge icon
          badge: string,
        }
        ),
        // Check if the commentable has comments
        hasComments: boolean,
        // Whether the object can have new comments or not
        acceptsNewComments: boolean,
        // Check if the current user can comment
        userAllowedToComment: boolean,
        // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
        alignment: number | null,
        // Check if the current user has reported the comment
        alreadyReported: boolean,
        // The number of comment's upVotes
        upVotes: number,
        // Check if the current user has upvoted the comment
        upVoted: boolean,
        // Check if the current user has downvoted the comment
        downVoted: boolean,
        // The number of comment's downVotes
        downVotes: number,
      }>,
    }>,
  }>,
};

export interface CommentDataFragment {
  // The Comment's unique ID
  id: string,
  // The Comment's signed global id
  sgid: string,
  // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
  type: string,
  // The comment message
  body: string,
  // The comment message ready to display (it is expected to include HTML)
  formattedBody: string,
  // The creation date of the comment
  createdAt: string,
  // The creation date of the comment in relative format
  formattedCreatedAt: string,
  // The resource author
  author: ({
    // The author's name
    name: string,
    // The author's nickname
    nickname: string,
    // The author's avatar url
    avatarUrl: string,
    // The author's profile path
    profilePath: string,
    // Whether the author's account has been deleted or not
    deleted: boolean,
    // The author's badge icon
    badge: string,
  } | {
    // The author's name
    name: string,
    // The author's nickname
    nickname: string,
    // The author's avatar url
    avatarUrl: string,
    // The author's profile path
    profilePath: string,
    // Whether the author's account has been deleted or not
    deleted: boolean,
    // The author's badge icon
    badge: string,
  }
  ),
  // Check if the commentable has comments
  hasComments: boolean,
  // Whether the object can have new comments or not
  acceptsNewComments: boolean,
  // Check if the current user can comment
  userAllowedToComment: boolean,
  // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
  alignment: number | null,
  // Check if the current user has reported the comment
  alreadyReported: boolean,
  // The number of comment's upVotes
  upVotes: number,
  // Check if the current user has upvoted the comment
  upVoted: boolean,
  // Check if the current user has downvoted the comment
  downVoted: boolean,
  // The number of comment's downVotes
  downVotes: number,
};

export interface CommentThreadFragment {
  // Check if the commentable has comments
  hasComments: boolean,
  // The Comment's unique ID
  id: string,
  // The Comment's signed global id
  sgid: string,
  // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
  type: string,
  // The comment message
  body: string,
  // The comment message ready to display (it is expected to include HTML)
  formattedBody: string,
  // The creation date of the comment
  createdAt: string,
  // The creation date of the comment in relative format
  formattedCreatedAt: string,
  // The resource author
  author: ({
    // The author's name
    name: string,
    // The author's nickname
    nickname: string,
    // The author's avatar url
    avatarUrl: string,
    // The author's profile path
    profilePath: string,
    // Whether the author's account has been deleted or not
    deleted: boolean,
    // The author's badge icon
    badge: string,
  } | {
    // The author's name
    name: string,
    // The author's nickname
    nickname: string,
    // The author's avatar url
    avatarUrl: string,
    // The author's profile path
    profilePath: string,
    // Whether the author's account has been deleted or not
    deleted: boolean,
    // The author's badge icon
    badge: string,
  }
  ),
  // Whether the object can have new comments or not
  acceptsNewComments: boolean,
  // Check if the current user can comment
  userAllowedToComment: boolean,
  // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
  alignment: number | null,
  // Check if the current user has reported the comment
  alreadyReported: boolean,
  // The number of comment's upVotes
  upVotes: number,
  // Check if the current user has upvoted the comment
  upVoted: boolean,
  // Check if the current user has downvoted the comment
  downVoted: boolean,
  // The number of comment's downVotes
  downVotes: number,
  comments: Array<{
    // The Comment's unique ID
    id: string,
    // The Comment's signed global id
    sgid: string,
    // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
    type: string,
    // The comment message
    body: string,
    // The comment message ready to display (it is expected to include HTML)
    formattedBody: string,
    // The creation date of the comment
    createdAt: string,
    // The creation date of the comment in relative format
    formattedCreatedAt: string,
    // The resource author
    author: ({
      // The author's name
      name: string,
      // The author's nickname
      nickname: string,
      // The author's avatar url
      avatarUrl: string,
      // The author's profile path
      profilePath: string,
      // Whether the author's account has been deleted or not
      deleted: boolean,
      // The author's badge icon
      badge: string,
    } | {
      // The author's name
      name: string,
      // The author's nickname
      nickname: string,
      // The author's avatar url
      avatarUrl: string,
      // The author's profile path
      profilePath: string,
      // Whether the author's account has been deleted or not
      deleted: boolean,
      // The author's badge icon
      badge: string,
    }
    ),
    // Check if the commentable has comments
    hasComments: boolean,
    // Whether the object can have new comments or not
    acceptsNewComments: boolean,
    // Check if the current user can comment
    userAllowedToComment: boolean,
    // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
    alignment: number | null,
    // Check if the current user has reported the comment
    alreadyReported: boolean,
    // The number of comment's upVotes
    upVotes: number,
    // Check if the current user has upvoted the comment
    upVoted: boolean,
    // Check if the current user has downvoted the comment
    downVoted: boolean,
    // The number of comment's downVotes
    downVotes: number,
    comments: Array<{
      // The Comment's unique ID
      id: string,
      // The Comment's signed global id
      sgid: string,
      // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
      type: string,
      // The comment message
      body: string,
      // The comment message ready to display (it is expected to include HTML)
      formattedBody: string,
      // The creation date of the comment
      createdAt: string,
      // The creation date of the comment in relative format
      formattedCreatedAt: string,
      // The resource author
      author: ({
        // The author's name
        name: string,
        // The author's nickname
        nickname: string,
        // The author's avatar url
        avatarUrl: string,
        // The author's profile path
        profilePath: string,
        // Whether the author's account has been deleted or not
        deleted: boolean,
        // The author's badge icon
        badge: string,
      } | {
        // The author's name
        name: string,
        // The author's nickname
        nickname: string,
        // The author's avatar url
        avatarUrl: string,
        // The author's profile path
        profilePath: string,
        // Whether the author's account has been deleted or not
        deleted: boolean,
        // The author's badge icon
        badge: string,
      }
      ),
      // Check if the commentable has comments
      hasComments: boolean,
      // Whether the object can have new comments or not
      acceptsNewComments: boolean,
      // Check if the current user can comment
      userAllowedToComment: boolean,
      // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
      alignment: number | null,
      // Check if the current user has reported the comment
      alreadyReported: boolean,
      // The number of comment's upVotes
      upVotes: number,
      // Check if the current user has upvoted the comment
      upVoted: boolean,
      // Check if the current user has downvoted the comment
      downVoted: boolean,
      // The number of comment's downVotes
      downVotes: number,
      comments: Array<{
        // The Comment's unique ID
        id: string,
        // The Comment's signed global id
        sgid: string,
        // The commentable's class name. i.e. `Decidim::ParticipatoryProcess`
        type: string,
        // The comment message
        body: string,
        // The comment message ready to display (it is expected to include HTML)
        formattedBody: string,
        // The creation date of the comment
        createdAt: string,
        // The creation date of the comment in relative format
        formattedCreatedAt: string,
        // The resource author
        author: ({
          // The author's name
          name: string,
          // The author's nickname
          nickname: string,
          // The author's avatar url
          avatarUrl: string,
          // The author's profile path
          profilePath: string,
          // Whether the author's account has been deleted or not
          deleted: boolean,
          // The author's badge icon
          badge: string,
        } | {
          // The author's name
          name: string,
          // The author's nickname
          nickname: string,
          // The author's avatar url
          avatarUrl: string,
          // The author's profile path
          profilePath: string,
          // Whether the author's account has been deleted or not
          deleted: boolean,
          // The author's badge icon
          badge: string,
        }
        ),
        // Check if the commentable has comments
        hasComments: boolean,
        // Whether the object can have new comments or not
        acceptsNewComments: boolean,
        // Check if the current user can comment
        userAllowedToComment: boolean,
        // The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'
        alignment: number | null,
        // Check if the current user has reported the comment
        alreadyReported: boolean,
        // The number of comment's upVotes
        upVotes: number,
        // Check if the current user has upvoted the comment
        upVoted: boolean,
        // Check if the current user has downvoted the comment
        downVoted: boolean,
        // The number of comment's downVotes
        downVotes: number,
      }>,
    }>,
  }>,
};

export interface DownVoteButtonFragment {
  // The Comment's unique ID
  id: string,
  // The number of comment's downVotes
  downVotes: number,
  // Check if the current user has downvoted the comment
  downVoted: boolean,
  // Check if the current user has upvoted the comment
  upVoted: boolean,
};

export interface UpVoteButtonFragment {
  // The Comment's unique ID
  id: string,
  // The number of comment's upVotes
  upVotes: number,
  // Check if the current user has upvoted the comment
  upVoted: boolean,
  // Check if the current user has downvoted the comment
  downVoted: boolean,
};
