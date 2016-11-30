import { random, name } from 'faker/locale/en';

const generateSessionData = () => {
  return {
    currentUser: {
      id: random.uuid(),
      name: name.findName()
    }
  };
};

export default generateSessionData;
