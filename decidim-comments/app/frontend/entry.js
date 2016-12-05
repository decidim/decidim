import loadTranslations from './support/load_translations';
import Comments         from './comments/comments.component';

require('react-dom');

// Expose globals for react-rails
window.Comments = Comments;

loadTranslations();
