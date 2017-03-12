import { date, image, lorem, name, random } from "faker/locale/en";

import { CommentFragment }           from "../support/schema";

/**
 * Generate random comment data to emulate a database real content
 * @param {number} num - The number of comments to generate random data
 * @returns {Object[]} - An array of objects representing comments data
 */
const generateCommentsData = (num = 1) => {
  let commentsData: CommentFragment[] = [];

  for (let idx = 0; idx < num; idx += 1) {
    commentsData.push({
      id: random.uuid(),
      type: "Decidim::Comments::Comment",
      body: lorem.words(),
      createdAt: date.past().toISOString(),
      author: {
        name: name.findName(),
        avatarUrl: image.imageUrl(),
      },
      hasComments: false,
      comments: [],
      acceptsNewComments: true,
      alignment: 0,
      upVotes: random.number(),
      upVoted: false,
      downVotes: random.number(),
      downVoted: false,
    });
  }

  return commentsData;
};

export default generateCommentsData;
