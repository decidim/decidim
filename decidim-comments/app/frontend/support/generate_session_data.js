import { random, name } from 'faker/locale/en';

/**
 * Generate random session data to emulate a database real content
 * @returns {Object} - An object representing session data
 */
const generateSessionData = () => {
  return {
    currentUser: {
      id: random.uuid(),
      name: name.findName()
    },
    locale: 'en'
  };
};

export default generateSessionData;
