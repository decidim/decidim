/* eslint-disable no-param-reassign */
import requireAll from "./require_all";

const { I18n } = require("react-i18nify");

/**
 * Load components translations from yaml files and import them into
 * react-i18ify system so they can be used via `I18n.t` method.
 * @returns {Void} - Nothing
 */
const loadTranslations = () => {
  const translationsContext = (<any> require).context("../../../config/locales/", true, /\.yml$/);
  const translationFiles = requireAll(translationsContext);

  const translations = translationsContext.keys().reduce((acc: any, key: string, index: number) => {
    const match = key.match(/\.\/(.*)\.yml/);

    if (match) {
      let locale = match[1];
      acc[locale] = translationFiles[index][locale].decidim;
    }

    return acc;
  }, {});

  I18n.setTranslations(translations);
};

/**
 * Load components translations from a locale files and import them into
 * react-i18ify system so they can be used via `I18n.t` method.
 * @returns {Void} - Nothing
 */
export const loadLocaleTranslations = (locale: string) => {
  const translationFile = require(`./../../../config/locales/${locale}.yml`);
  const translations = Object.keys(translationFile).reduce((acc: any, key: string) => {
    acc[locale] = translationFile[locale].decidim;
    return acc;
  }, {});

  I18n.setTranslations(translations);
};

export default loadTranslations;
