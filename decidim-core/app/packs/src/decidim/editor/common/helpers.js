export const uniqueId = (prefix) => {
  return `${prefix}-${(new Date()).getTime()}-${Math.random().toString(16).slice(2)}`;
};
