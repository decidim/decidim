import { name } from 'faker/locale/en';

/**
 * Generate random current user data to emulate a database real content
 * @returns {Object} - An object representing current user data
 */
const generateCurrentUserData = () => {
  return {
    name: name.findName()
  };
};

export default generateCurrentUserData;
