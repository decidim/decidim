/* eslint-disable no-console */

const FAKE_ENCRYPTION_TIME = 1000; // 1s

((exports) => {
  class PreviewVoteComponent {
    constructor({ electionUniqueId, voterUniqueId }) {
      this.electionUniqueId = electionUniqueId;
      this.voterUniqueId = voterUniqueId;
    }

    async bindEvents({
      onBindEncryptButton,
      onStart,
      onVoteEncryption,
      castOrAuditBallot,
      onBindAuditBallotButton,
      onBindCastBallotButton,
      onAuditBallot,
      onCastBallot,
      onAuditComplete,
      onCastComplete,
      onInvalid,
    }) {
      onBindEncryptButton(async () => {
        onStart();
        onVoteEncryption(
          (plainVote) => {
            this.fakeEncrypt(plainVote).then((ballot) => {
              castOrAuditBallot(ballot);
              onBindAuditBallotButton(() => {
                onAuditBallot(
                  ballot,
                  `${this.voterUniqueId}-election-${this.electionUniqueId}.txt`
                );
                onAuditComplete();
              });

              onBindCastBallotButton(async () => {
                await onCastBallot(ballot);
                onCastComplete();
              });
            });
          },
          () => {
            onInvalid();
          }
        );
      });
    }
    async fakeEncrypt(plainVote) {
      await new Promise((resolve) => setTimeout(resolve, FAKE_ENCRYPTION_TIME));

      return {
        encryptedData: plainVote,
        encryptedDataHash: this.generateHexString(64),
        auditableData: plainVote,
      };
    }
    generateHexString(length) {
      return Array(length)
        .fill("")
        .map((v) => Math.random().toString(16).charAt(2))
        .join("");
    }
  }

  function setupVoteComponent($voteWrapper) {
    const voterUniqueId = $voteWrapper.data("voterId");
    const electionUniqueId = $voteWrapper.data("electionUniqueId");

    return new PreviewVoteComponent({
      electionUniqueId,
      voterUniqueId,
    });
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.setupVoteComponent = setupVoteComponent;
})(window);
