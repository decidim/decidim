export const truncateFilename = (filename, maxLength = 31) => {
  if (filename.length <= maxLength) {
    return filename;
  }

  const charactersFromBegin = Math.floor(maxLength / 2) - 3;
  const charactersFromEnd = maxLength - charactersFromBegin - 3;
  return `${filename.slice(0, charactersFromBegin)}...${filename.slice(-charactersFromEnd)}`;
}
