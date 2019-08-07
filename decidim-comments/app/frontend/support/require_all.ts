/**
 * Given a webpack require context it require all the files
 * @param {Object} requireContext - A webpack require context
 * @returns {Object[]} - An array of webpack modules
 */
const requireAll = (requireContext: any) => {
  return requireContext.keys().map(requireContext);
};

export default requireAll;
