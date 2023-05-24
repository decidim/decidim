import "src/decidim/elections/election_log";
import "src/decidim/elections/trustee/key_ceremony";
import "src/decidim/elections/trustee/tally";
import "src/decidim/elections/trustee/trustee_zone";

// REDESIGN_PENDING: setup-vote and setup-preview MUST NOT LOAD at the same time
// they should be loaded asynchronously depending "preview_mode?" rails variable
// thourgh "async imports", see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/import
import "src/decidim/elections/voter/setup-vote";
import "src/decidim/elections/voter/setup-preview";

import "src/decidim/elections/voter/casting-vote";
import "src/decidim/elections/voter/new-vote";
import "src/decidim/elections/voter/verify-vote";

// Images
require.context("../images", true)

// CSS
import "stylesheets/decidim/elections/elections.scss"
