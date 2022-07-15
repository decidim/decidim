/* eslint-disable require-jsdoc */

// show a message to the user if comunication is lost
import "src/decidim/elections/broken_promises_handler";
import { VoteComponent } from "@decidim/decidim-bulletin_board";

import * as VotingSchemesDummy from "@decidim/voting_schemes-dummy";
const DummyVoterWrapperAdapter = VotingSchemesDummy.VoterWrapperAdapter;
import * as VotingSchemesElectionGuard from "@decidim/voting_schemes-electionguard";
const ElectionGuardVoterWrapperAdapter =
  VotingSchemesElectionGuard.VoterWrapperAdapter;

export default function setupVoteComponent($voteWrapper) {
  // Data
  const bulletinBoardClientParams = {
    apiEndpointUrl: $voteWrapper.data("apiEndpointUrl")
  };
  const electionUniqueId = $voteWrapper.data("electionUniqueId");
  const authorityPublicKeyJSON = JSON.stringify(
    $voteWrapper.data("authorityPublicKey")
  );
  const voterUniqueId = $voteWrapper.data("voterId");
  const schemeName = $voteWrapper.data("schemeName");

  // Use the correct voter wrapper adapter
  let voterWrapperAdapter = null;

  if (schemeName === "dummy") {
    voterWrapperAdapter = new DummyVoterWrapperAdapter({
      voterId: voterUniqueId
    });
  } else if (schemeName === "electionguard") {
    voterWrapperAdapter = new ElectionGuardVoterWrapperAdapter({
      voterId: voterUniqueId,
      workerUrl: "/assets/electionguard/webworker.js"
    });
  } else {
    throw new Error(`Voting scheme ${schemeName} not supported.`);
  }

  // Returns the vote component
  return new VoteComponent({
    bulletinBoardClientParams,
    authorityPublicKeyJSON,
    electionUniqueId,
    voterUniqueId,
    voterWrapperAdapter
  });
}

window.Decidim = window.Decidim || {};
window.Decidim.setupVoteComponent = setupVoteComponent;

