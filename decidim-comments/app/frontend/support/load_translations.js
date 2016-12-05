/* eslint-disable no-param-reassign */
import { I18n } from 'react-i18nify';

const requireAll = (requireContext) => {
  return requireContext.keys().map(requireContext);
};

const loadTranslations = () => {
  const translationsContext = require.context('../../../config/locales/', true, /\.yml$/);
  const translationFiles = requireAll(translationsContext);

  const translations = translationsContext.keys().reduce((acc, key, index) => {
    const locale = key.match(/\.\/(.*)\.yml/)[1];
    acc[locale] = translationFiles[index][locale].decidim;
    return acc;
  }, {});

  I18n.setTranslations(translations);
};

export default loadTranslations;
