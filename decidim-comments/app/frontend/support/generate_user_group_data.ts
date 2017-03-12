import { company, random } from "faker/locale/en";

/**
 * Generate random user group data to emulate a database real content
 * @returns {Object} - An object representing user group data
 */
const generateUserGrouprData = () => {
  return {
    id: random.uuid(),
    name: company.companyName(),
  };
};

export default generateUserGrouprData;
