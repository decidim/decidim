/**
 * This file is responsible to get LogEntries
 * for an election for the election log.
 */
import { Client, MessageParser } from "@codegram/decidim-bulletin_board";

$(async () => {
  // UI Elements
  const $electionLog = $(".election-log");
  const $createElectionStep = $electionLog.find("#create-election-step")
  const $keyCeremonyStep = $electionLog.find("#key-ceremony-step")
  const $voteStep = $electionLog.find("#vote-step")
  const $tallyStep = $electionLog.find("#tally-step")
  const $resultStep = $electionLog.find("#results-step")

  // Data
  const authorityPublicKeyJSON = JSON.stringify($electionLog.data("authorityPublicKey"))
  const bulletinBoardClient = new Client({
    apiEndpointUrl: $electionLog.data("apiEndpointUrl")
  });
  const electionUniqueId = `${$electionLog.data("authoritySlug")}.${$electionLog.data("electionId")}`
  const parser = new MessageParser({ authorityPublicKeyJSON })
  const logEntries = await bulletinBoardClient.getElectionLogEntries({electionUniqueId: electionUniqueId, types: ["create_election", "start_key_ceremony", "end_key_ceremony", "start_vote", "end_vote", "start_tally", "end_tally", "publish_results"]});

  // Functions to be used for each step

  // adds the `iat` of the message to the UI
  const setMessageTime = async (logEntryStep, uiStep) => {
    const messageId = logEntryStep.messageId
    const signedData = logEntryStep.signedData
    const parsedData = await parser.parse({messageId, signedData})
    const messageTime = new Date(parsedData.decodedData.iat * 1000)
    const year = messageTime.toDateString()
    const time = messageTime.toLocaleTimeString()

    uiStep.find(".time").html(`${year} ${time}`)
  }

  // adds the chained Hash of the message to the UI
  const addChainedHash = (logEntryStep, uiStep) => {
    uiStep.find(".card__footer--transparent").removeClass("hide")
    uiStep.find(".chained-hash").html(logEntryStep.chainedHash)
  }

  // CREATE ELECTION STEP
  const createElectionLogEntry = logEntries.find((logEntry) => logEntry.messageId.includes("create_election"))
  if (createElectionLogEntry) {
    $createElectionStep.find(".no-election-created").addClass("hide")
    $createElectionStep.find(".election-created").removeClass("hide")

    await setMessageTime(createElectionLogEntry, $createElectionStep)

    addChainedHash(createElectionLogEntry, $createElectionStep)
  }

  // KEY CEREMONY STEP
  const startKeyCeremonyLogEntry = logEntries.find((logEntry) => logEntry.messageId.includes("start_key_ceremony"))
  const endKeyCeremonyLogEntry = logEntries.find((logEntry) => logEntry.messageId.includes("end_key_ceremony"))

  if (startKeyCeremonyLogEntry && !endKeyCeremonyLogEntry) {
    $keyCeremonyStep.find(".key-ceremony-not-started").addClass("hide")
    $keyCeremonyStep.find(".card__text").removeClass("hide")

    await setMessageTime(startKeyCeremonyLogEntry, $keyCeremonyStep)

    $keyCeremonyStep.find(".key-ceremony-started").removeClass("hide")
    addChainedHash(startKeyCeremonyLogEntry, $keyCeremonyStep)
  } else if (endKeyCeremonyLogEntry) {
    $keyCeremonyStep.find(".key-ceremony-not-started").addClass("hide")
    $keyCeremonyStep.find(".card__text").removeClass("hide")

    await setMessageTime(endKeyCeremonyLogEntry, $keyCeremonyStep)

    $keyCeremonyStep.find(".key-ceremony-started").addClass("hide")
    $keyCeremonyStep.find(".key-ceremony-completed").removeClass("hide")
    addChainedHash(endKeyCeremonyLogEntry, $keyCeremonyStep)
  }

  // VOTING STEP
  const startVoteLogEntry = logEntries.find((logEntry) => logEntry.messageId.includes("start_vote"))
  const endVoteLogEntry = logEntries.find((logEntry) => logEntry.messageId.includes("end_vote"))

  if (startVoteLogEntry && !endVoteLogEntry) {
    $voteStep.find(".vote-not-started").addClass("hide")
    $voteStep.find(".card__text").removeClass("hide")

    await setMessageTime(startVoteLogEntry, $voteStep)

    $voteStep.find(".vote-started").removeClass("hide")
    addChainedHash(startVoteLogEntry, $voteStep)
  } else if (endVoteLogEntry) {
    $voteStep.find(".vote-not-started").addClass("hide")
    $voteStep.find(".card__text").removeClass("hide")

    await setMessageTime(endVoteLogEntry, $voteStep)

    $voteStep.find(".vote-started").addClass("hide")
    $voteStep.find(".vote-completed").removeClass("hide")
    addChainedHash(endVoteLogEntry, $voteStep)
  }

  // TALLY STEP
  const startTallyLogEntry = logEntries.find((logEntry) => logEntry.messageId.includes("start_tally"))
  const endTallyLogEntry = logEntries.find((logEntry) => logEntry.messageId.includes("end_tally"))

  if (startTallyLogEntry && !endTallyLogEntry) {
    $tallyStep.find(".tally-not-started").addClass("hide")
    $tallyStep.find(".card__text").removeClass("hide")

    await setMessageTime(startTallyLogEntry, $tallyStep)

    $tallyStep.find(".tally-started").removeClass("hide")
    addChainedHash(startTallyLogEntry, $tallyStep)
  } else if (endTallyLogEntry) {
    $tallyStep.find(".tally-not-started").addClass("hide")
    $tallyStep.find(".card__text").removeClass("hide")

    await setMessageTime(endTallyLogEntry, $tallyStep)

    $tallyStep.find(".tally-started").addClass("hide")
    $tallyStep.find(".tally-completed").removeClass("hide")
    addChainedHash(endTallyLogEntry, $tallyStep)
  }

  // RESULTS STEP
  const resultsLogEntry = logEntries.find((logEntry) => logEntry.messageId.includes("publish_results"))

  if (resultsLogEntry) {
    $resultStep.find(".results-not-published").addClass("hide")
    $resultStep.find(".card__text").removeClass("hide")

    await setMessageTime(resultsLogEntry, $resultStep)

    $resultStep.find(".results-published").removeClass("hide")
    addChainedHash(resultsLogEntry, $resultStep)
  } 
});
