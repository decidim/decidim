import "src/decidim/elections/election_log";
import "src/decidim/elections/trustee/key_ceremony";
import "src/decidim/elections/trustee/tally";
import "src/decidim/elections/trustee/trustee_zone";

// both setup-vote and setup-preview MUST LOAD BEFORE new-vote
// as they're imported from the window object
import "src/decidim/elections/voter/setup-vote";
import "src/decidim/elections/voter/setup-preview";
import "src/decidim/elections/voter/casting-vote";
import "src/decidim/elections/voter/new-vote";
import "src/decidim/elections/voter/verify-vote";

// Images
require.context("../images", true)

// CSS
import "stylesheets/decidim/elections/elections.scss"
