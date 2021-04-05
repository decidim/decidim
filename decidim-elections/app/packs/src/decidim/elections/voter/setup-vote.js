// TODO-blat
// = require decidim/bulletin_board/decidim-bulletin_board

// Note: these gems will be moved to the application in the next release
// = require voting_schemes/dummy/dummy
// = require voting_schemes/electionguard/electionguard

export default function setupVoteComponent($voteWrapper) {
  const { VoteComponent } = window.decidimBulletinBoard;
  const {
    VoterWrapperAdapter: DummyVoterWrapperAdapter
  } = window.dummyVotingScheme;
  const {
    VoterWrapperAdapter: ElectionGuardVoterWrapperAdapter
  } = window.electionGuardVotingScheme;

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
