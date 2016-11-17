import React    from 'react';
import ReactDOM from 'react-dom';

import Comments from './comments/comments.component';

// Expose globals for react-rails
window.React = React;
window.ReactDOM = ReactDOM;
window.Comments = Comments;
