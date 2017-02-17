/* eslint-disable no-param-reassign */
import { I18n }   from 'react-i18nify';
import requireAll from './require_all';

/**
 * Load components translations from yaml files and import them into
 * react-i18ify system so they can be used via `I18n.t` method.
 * @returns {Void} - Nothing
 */
const loadTranslations = () => {
  const translationsContext = require.context('../../../config/locales/', true, /\.yml$/);
  const translationFiles = requireAll(translationsContext);

  const translations = translationsContext.keys().reduce((acc: any, key: string, index: number) => {
    const locale = key.match(/\.\/(.*)\.yml/)[1];
    acc[locale] = translationFiles[index][locale].decidim;
    return acc;
  }, {});

  I18n.setTranslations(translations);
};

export default loadTranslations;
