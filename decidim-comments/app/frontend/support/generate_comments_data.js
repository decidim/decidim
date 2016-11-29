import { random, name, date } from 'faker/locale/en';

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
