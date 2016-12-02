/* eslint-disable import/first */

require('es6-object-assign').polyfill();
require('react-dom');

import Comments from './comments/comments.component';

// Expose globals for react-rails
window.Comments = Comments;
