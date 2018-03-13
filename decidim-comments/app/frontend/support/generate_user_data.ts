import { name } from "faker/locale/en";

/**
 * Generate random user data to emulate a database real content
 * @returns {Object} - An object representing user data
 */
const generateUserData = () => {
  return {
    name: `${name.firstName()} ${name.lastName()}`,
    nickname: `@${name.findName()}`
  };
};

export default generateUserData;
