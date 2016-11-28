import { random, name } from 'faker/locale/en';

const generateCommentsData = (num = 1) => {
  let commentsData = {
    comments: []
  };

  for (let idx = 0; idx < num; idx += 1) {
    commentsData.comments.push({
      id: random.uuid(),
      body: random.words(),
      author: {
        name: name.findName()
      }
    })
  }

  return commentsData;
};

export default generateCommentsData;
