# frozen_string_literal: true

require "spec_helper"

module Decidim::Elections
  describe CurrentUserVoteFlow do
    subject(:vote_flow) { described_class.new(election, user) { allowed } }

    let(:election) { create(:election, **election_params) }
    let(:election_params) do
      {
        id: 10_000,
        created_at: Time.new(2000, 1, 1, 0, 0, 0, 0),
        salt: "bcef77cedb2d1269dd52466873cf5d7695365b91111e9adf08583cfe95e6c607",
        **election_params_changes
      }
    end
    let(:election_params_changes) { {} }
    let(:user) { create(:user, **user_params) }
    let(:user_params) do
      {
        id: 10_000,
        created_at: Time.new(2000, 1, 1, 0, 0, 0, 0),
        organization: election.component.organization,
        **user_params_changes
      }
    end
    let(:user_params_changes) { {} }
    let(:allowed) { true }
    let(:valid_voter_id) { "43e9f7d91e3a075cb651ff0e82ac10ff62a1f406dcf32213e3ffce08d2f2f876" }

    describe "#voter_id" do
      subject { vote_flow.voter_id }

      it { is_expected.to eq(valid_voter_id) }

      {
        "e3108b0731043e94061fd4730b58c03328a04f90a37743e71aa777c7f0bfda8a" => { id: 10_001 },
        "6b2160caf1ff46ada67c43bba3c46396cde776dc5e00e468682824a83a836c14" => { created_at: Time.new(2000, 1, 1, 0, 0, 0, 1) }
      }.each do |voter_id, user_changes|
        context "when changing the user data with #{user_changes.to_json}" do
          let(:user_params_changes) { user_changes }

          it { is_expected.to eq(voter_id) }
        end
      end

      {
        "d28ecf10691236f9e991f149a9afe7dc7a006c761069ccb29052677de97ef853" => { id: 10_001 },
        "341d98eb8494e9a32fcc99dabb766e8b8dfc7ad0e7d6d6d68ebe2570a3454a70" => { created_at: Time.new(2000, 1, 1, 0, 0, 0, 1) },
        "459027d2c994a9491780d68ca5ef043e6419e8806c893b717cd2dcd5b32046c0" => { salt: "ccef77cedb2d1269dd52466873cf5d7695365b91111e9adf08583cfe95e6c607" }
      }.each do |voter_id, election_changes|
        context "when changing the election data with #{election_changes.to_json}" do
          let(:election_params_changes) { election_changes }

          it { is_expected.to eq(voter_id) }
        end
      end
    end

    describe "#voter_id_token" do
      subject { vote_flow.voter_id_token(voter_id) }

      let(:voter_id) { nil }

      it { is_expected.to eq("b8489d9390b2b1886f28") }

      context "when receiving a voter id" do
        let(:voter_id) { "2f222a608b5e43704bd7c22b8f582eeedb0cd64bc8b99a599d6028f3295ed90a" }

        it { is_expected.to eq("7137159cf614abe35d9a") }
      end
    end

    context "with time dependant validations" do
      before { travel_to(now) }

      let(:now) { Time.new(2000, 1, 1, 0, 0, 0, 0) }
      let(:valid_token) { "M3TF3yp1KNfxclpeKGkbvIsjezpKtETOu3iEniMxWkJ86Af0d2GQZB4Yx2PbZNE9WdfleiAYaVuRq+fiC179DzWc+NzlwsdaK6WHjBte2G9LcEr7XnOhIEVcPfLI3G9jdJkL+JTxPt2T3PQnHDNnNAvcCU2sf+bWwekECGzuEZHknpM605Y2qRQfZG78Y6F17pv7u7S0e+z/CzakCcTVwOphcf2x9n+8Sy/Of7zMPO+Rbrl2KImIfpetXSvuEMcH4g/T2omCvtDvDyCPR8e8jHvlp4fAdiDU8nRX28M/xa6Vkx15MjOVfcS/NqrNMU7IxWN+xXimaausObOSkuwgb2Jq0wtoXCcDiw/SgVdr1y+o+LzqfqX+gqFL7nAgQA96WJ2SVHDo0TLybTeiPBV1MQwM/gJbRyaIjvfMKt0Q0EkPkUfJxLbt/MtUizmitLUWVNsCwqJkkV3x--rMnBzxE1CoHEpKEB--IdLlo8iGMec4qhii0/Lzwg==" }
      let(:invalid_token) { "A3TF3yp1KNfxclpeKGkbvIsjezpKtETOu3iEniMxWkJ86Af0d2GQZB4Yx2PbZNE9WdfleiAYaVuRq+fiC179DzWc+NzlwsdaK6WHjBte2G9LcEr7XnOhIEVcPfLI3G9jdJkL+JTxPt2T3PQnHDNnNAvcCU2sf+bWwekECGzuEZHknpM605Y2qRQfZG78Y6F17pv7u7S0e+z/CzakCcTVwOphcf2x9n+8Sy/Of7zMPO+Rbrl2KImIfpetXSvuEMcH4g/T2omCvtDvDyCPR8e8jHvlp4fAdiDU8nRX28M/xa6Vkx15MjOVfcS/NqrNMU7IxWN+xXimaausObOSkuwgb2Jq0wtoXCcDiw/SgVdr1y+o+LzqfqX+gqFL7nAgQA96WJ2SVHDo0TLybTeiPBV1MQwM/gJbRyaIjvfMKt0Q0EkPkUfJxLbt/MtUizmitLUWVNsCwqJkkV3x--rMnBzxE1CoHEpKEB--IdLlo8iGMec4qhii0/Lzwg==" }

      context "when a voter token was not received" do
        it { expect(subject).not_to be_valid_received_data }

        it "generates a token with the token data" do
          generated_data = vote_flow.send(:message_encryptor).decrypt_and_verify(subject.voter_token)
          expect(generated_data).to eq(vote_flow.send(:voter_token_data).to_json)
        end
      end

      context "when a valid voter token was received" do
        before { vote_flow.voter_from_token(voter_token: valid_token, voter_id: valid_voter_id) }

        it { expect(subject).to be_valid_received_data }
        it { expect(subject.voter_token).to eq(valid_token) }

        context "when the voter token has expired" do
          let(:now) { Time.new(2000, 1, 1, 3, 0, 0, 0) }

          it { expect(subject).not_to be_valid_received_data }
          it { expect(subject.voter_token).to eq(valid_token) }
        end
      end

      context "when a wrong voter token was received" do
        before { vote_flow.voter_from_token(voter_token: invalid_token, voter_id: valid_voter_id) }

        it { expect(subject).not_to be_valid_received_data }
        it { expect(subject.voter_token).to eq(invalid_token) }
      end
    end

    describe "user based attributes and methods" do
      it { expect(subject).to have_voter }
      it { expect(subject.user).to eq(user) }
      it { expect(subject.email).to eq(user.email) }
      it { expect(subject.voter_name).to eq(user.name) }
      it { expect(subject.voter_data).to eq(id: user.id, created: user.created_at.to_i) }

      context "when there is no user" do
        let(:user) { nil }

        it { expect(subject).not_to have_voter }
        it { expect(subject.user).to be_nil }
        it { expect(subject.email).to be_nil }
        it { expect(subject.voter_name).to be_nil }
        it { expect(subject.voter_data).to be_nil }
      end
    end

    describe "#vote_check" do
      subject { vote_flow.vote_check }

      it { expect(subject).to be_allowed }

      context "when there is no user" do
        let(:user) { nil }

        it { expect(subject.error_message).to eq("You are not allowed to vote on this election at this moment.") }
      end

      context "when the user is not authorized to vote" do
        let(:allowed) { false }

        it { expect(subject.error_message).to eq("You are not allowed to vote on this election at this moment.") }
      end
    end

    describe "#login_path" do
      subject { vote_flow.login_path("a vote path") }

      it { expect(subject).to be_nil }
    end

    describe "#questions_for" do
      subject { vote_flow.questions_for(election) }

      it { expect(subject).to match_array(election.questions) }
    end

    describe "#ballot_style_id" do
      subject { vote_flow.ballot_style_id }

      it { expect(subject).to be_nil }
    end
  end
end
