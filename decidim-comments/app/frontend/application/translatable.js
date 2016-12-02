/* eslint-disable import/no-dynamic-require, no-param-reassign, global-require */
import { snakeCase } from 'lodash';
import { I18n }      from 'react-i18nify';

let availableLocales = ['en', 'es', 'ca'];

let translations = availableLocales.reduce((acc, locale) => {
  acc[locale] = {};
  return acc;
}, {});

const loadTranslations = (componentName) => {
  const componentTranslations = availableLocales.reduce((acc, locale) => {
    acc[locale] = require(`../../../config/locales/components/${componentName}.${locale}.yml`)[locale];
    return acc;
  }, {});

  translations = availableLocales.reduce((acc, locale) => {
    acc[locale] = {
      ...translations[locale],
      ...componentTranslations[locale].components
    };
    return acc;
  }, {});

  I18n.setTranslations(translations);
};

const Translatable = () => (target) => {
  loadTranslations(snakeCase(target.name));
};

export default Translatable;
