/**
 * This file is responsible to get LogEntries
 * for an election for the election log.
 */
import { Client, MessageParser } from "@decidim/decidim-bulletin_board";

$(async () => {
  // UI Elements
  const $electionLog = $("#election-log");

  if ($electionLog.length) {
    const $createElectionStep = $electionLog.find("#create-election-step");
    const $keyCeremonyStep = $electionLog.find("#key-ceremony-step");
    const $voteStep = $electionLog.find("#vote-step");
    const $tallyStep = $electionLog.find("#tally-step");
    const $resultStep = $electionLog.find("#results-step");

    // Data
    const authorityPublicKeyJSON = JSON.stringify(
      $electionLog.data("authorityPublicKey")
    );
    const bulletinBoardClient = new Client({
      apiEndpointUrl: $electionLog.data("apiEndpointUrl")
    });
    const electionUniqueId = `${$electionLog.data(
      "authoritySlug"
    )}.${$electionLog.data("electionId")}`;
    const parser = new MessageParser({ authorityPublicKeyJSON });
    const logEntries = await bulletinBoardClient.getElectionLogEntries({
      electionUniqueId: electionUniqueId,
      types: [
        "create_election",
        "start_key_ceremony",
        "end_key_ceremony",
        "start_vote",
        "end_vote",
        "start_tally",
        "end_tally",
        "publish_results"
      ]
    });

    // Functions to be used for each step

    // adds the `iat` of the message to the UI
    const setMessageTime = async (logEntryStep, uiStep) => {
      if (!logEntryStep.signedData) {
        uiStep.find("[data-time]").html("");
        return;
      }

      const parsedData = await parser.parse(logEntryStep);
      const messageTime = new Date(parsedData.decodedData.iat * 1000);
      const year = messageTime.toDateString();
      const time = messageTime.toLocaleTimeString();

      uiStep.find("[data-time]").html(`${year} ${time}`);
    };

    // adds the chained Hash of the message to the UI
    const addChainedHash = (logEntryStep, uiStep) => {
      const $hash = uiStep.find("[data-chained-hash]");

      $hash.parent().attr("hidden", false);
      $hash.html(logEntryStep.chainedHash);
    };

    // finds the logEntry for each step
    const getLogEntryByMessageId = (step) => {
      return logEntries.find((logEntry) => logEntry.messageId.includes(step));
    };

    // CREATE ELECTION STEP
    const createElectionLogEntry = getLogEntryByMessageId("create_election");
    if (createElectionLogEntry) {
      $createElectionStep.find("[data-no-election-created]").attr("hidden", true);
      $createElectionStep.find("[data-election-created]").attr("hidden", false);

      await setMessageTime(createElectionLogEntry, $createElectionStep);

      addChainedHash(createElectionLogEntry, $createElectionStep);
    }

    // KEY CEREMONY STEP
    const startKeyCeremonyLogEntry = getLogEntryByMessageId("start_key_ceremony");
    const endKeyCeremonyLogEntry = getLogEntryByMessageId("end_key_ceremony");

    if (startKeyCeremonyLogEntry && !endKeyCeremonyLogEntry) {
      $keyCeremonyStep.find("[data-key-ceremony-not-started]").attr("hidden", true);

      await setMessageTime(startKeyCeremonyLogEntry, $keyCeremonyStep);

      $keyCeremonyStep.find("[data-key-ceremony-started]").attr("hidden", false);
      addChainedHash(startKeyCeremonyLogEntry, $keyCeremonyStep);
    } else if (endKeyCeremonyLogEntry) {
      $keyCeremonyStep.find("[data-key-ceremony-not-started]").attr("hidden", true);

      await setMessageTime(endKeyCeremonyLogEntry, $keyCeremonyStep);

      $keyCeremonyStep.find("[data-key-ceremony-started]").attr("hidden", true);
      $keyCeremonyStep.find("[data-key-ceremony-completed]").attr("hidden", false);
      addChainedHash(endKeyCeremonyLogEntry, $keyCeremonyStep);
    }

    // VOTING STEP
    const startVoteLogEntry = getLogEntryByMessageId("start_vote");
    const endVoteLogEntry = getLogEntryByMessageId("end_vote");

    if (startVoteLogEntry && !endVoteLogEntry) {
      $voteStep.find("[data-vote-not-started]").attr("hidden", true);

      await setMessageTime(startVoteLogEntry, $voteStep);

      $voteStep.find("[data-vote-started]").attr("hidden", false);
      addChainedHash(startVoteLogEntry, $voteStep);
    } else if (endVoteLogEntry) {
      $voteStep.find("[data-vote-not-started]").attr("hidden", true);

      await setMessageTime(endVoteLogEntry, $voteStep);

      $voteStep.find("[data-vote-started]").attr("hidden", true);
      $voteStep.find("[data-vote-completed]").attr("hidden", false);
      addChainedHash(endVoteLogEntry, $voteStep);
    }

    // TALLY STEP
    const startTallyLogEntry = getLogEntryByMessageId("start_tally");
    const endTallyLogEntry = getLogEntryByMessageId("end_tally");

    if (startTallyLogEntry && !endTallyLogEntry) {
      $tallyStep.find("[data-tally-not-started]").attr("hidden", true);

      await setMessageTime(startTallyLogEntry, $tallyStep);

      $tallyStep.find("[data-tally-started]").attr("hidden", false);
      addChainedHash(startTallyLogEntry, $tallyStep);
    } else if (endTallyLogEntry) {
      $tallyStep.find("[data-tally-not-started]").attr("hidden", true);

      await setMessageTime(endTallyLogEntry, $tallyStep);

      $tallyStep.find("[data-tally-started]").attr("hidden", true);
      $tallyStep.find("[data-tally-completed]").attr("hidden", false);
      addChainedHash(endTallyLogEntry, $tallyStep);
    }

    // RESULTS STEP
    const resultsLogEntry = getLogEntryByMessageId("publish_results");

    if (resultsLogEntry) {
      $resultStep.find("[data-results-not-published]").attr("hidden", true);

      await setMessageTime(resultsLogEntry, $resultStep);

      $resultStep.find("[data-results-published]").attr("hidden", false);
      addChainedHash(resultsLogEntry, $resultStep);
    }
  }
});
