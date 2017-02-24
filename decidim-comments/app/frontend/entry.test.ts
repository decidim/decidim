// ---------------------------------------
// Test Environment Setup
// ---------------------------------------
import loadTranslations from './support/load_translations';
import requireAll       from './support/require_all';

require('jquery');

// ---------------------------------------
// Require Tests
// ---------------------------------------
requireAll((<any> require).context('./application/', true, /\.test\.tsx?$/));
requireAll((<any> require).context('./comments/', true, /\.test\.tsx?$/));

// Load component locales from yaml files
loadTranslations();
