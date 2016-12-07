import { random, name, date } from 'faker/locale/en';

/** 
 * Generate random comment data to emulate a database real content
 * @param {number} num - The number of comments to generate random data
 * @returns {Object[]} - An array of objects representing comments data
 */
const generateCommentsData = (num = 1) => {
  let commentsData = {
    comments: []
  };

  for (let idx = 0; idx < num; idx += 1) {
    commentsData.comments.push({
      id: random.uuid(),
      body: random.words(),
      createdAt: date.past().toString(),
      author: {
        name: name.findName()
      }
    })
  }

  return commentsData;
};

export default generateCommentsData;
