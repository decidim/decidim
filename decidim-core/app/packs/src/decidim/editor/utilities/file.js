export const fileNameToTitle = (fileName) => {
  return fileName.split(".").slice(0, -1).join(".");
};
