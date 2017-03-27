const assetUrl = (name: string): string => {
  const url = window.DecidimComments.assets[name];

  if (!url) {
    throw new Error(`Asset "${name}" can't be found on decidim comments manifest.`);
  }

  return url;
};

export default assetUrl;
