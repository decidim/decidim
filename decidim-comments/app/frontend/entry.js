import loadTranslations from './support/load_translations';
import Comments         from './comments/comments.component';

// Dependency for react-rails. It is exposed globally by webpack
require('react-dom');

// Expose globals for react-rails
window.Comments = Comments;

// Load component locales from yaml files
loadTranslations();
