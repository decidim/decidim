import { date, image, lorem, name, random } from "faker/locale/en";

import { CommentFragment } from "../support/schema";

/**
 * Generate random comment data to emulate a database real content
 * @param {number} num - The number of comments to generate random data
 * @returns {Object[]} - An array of objects representing comments data
 */
const generateCommentsData = (num = 1) => {
  const commentsData: CommentFragment[] = [];

  for (let idx = 0; idx < num; idx += 1) {
    const creationDate = date.recent();
    const nickname = name.findName();

    commentsData.push({
      id: random.uuid(),
      type: "Decidim::Comments::Comment",
      body: lorem.words(),
      formattedBody: lorem.words(),
      createdAt: creationDate.toISOString(),
      formattedCreatedAt: creationDate.toLocaleTimeString(),
      author: {
        name: `${name.firstName()} ${name.lastName()}`,
        nickname: `@${nickname}`,
        avatarUrl: image.imageUrl(),
        profilePath: `/profiles/${nickname}`,
        deleted: false,
        badge: "verified-badge"
      },
      hasComments: false,
      comments: [],
      acceptsNewComments: true,
      userAllowedToComment: true,
      alignment: 0,
      upVotes: random.number(),
      upVoted: false,
      downVotes: random.number(),
      downVoted: false,
      sgid: random.uuid(),
      alreadyReported: false
    });
  }

  return commentsData;
};

export default generateCommentsData;
