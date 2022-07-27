# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings
  describe CensusVoteFlow do
    subject(:vote_flow) { described_class.new(election) }

    let(:dataset) { create(:dataset, voting:) }
    let(:election) { create(:election, component:, **election_params) }
    let(:component) { create(:elections_component, participatory_space: voting) }
    let(:voting) { create(:voting) }
    let(:election_params) do
      {
        id: 10_000,
        created_at: Time.new(2000, 1, 1, 0, 0, 0, 0),
        salt: "bcef77cedb2d1269dd52466873cf5d7695365b91111e9adf08583cfe95e6c607",
        **election_params_changes
      }
    end
    let(:election_params_changes) { {} }
    let!(:datum) { create(:datum, :with_access_code, **datum_params) }
    let(:datum_params) do
      {
        id: 10_000,
        created_at: Time.new(2000, 1, 1, 0, 0, 0, 0),
        full_name: "A. Very Nice Name",
        email: "voter@example.org",
        document_type:,
        document_number:,
        birthdate:,
        postal_code:,
        access_code:,
        dataset:,
        **datum_params_changes
      }
    end
    let(:datum_params_changes) { {} }
    let(:document_type) { "DNI" }
    let(:document_number) { "00000001R" }
    let(:birthdate) { Date.civil(1980, 1, 1) }
    let(:postal_code) { "08001" }
    let(:access_code) { "1234ABCD" }

    let(:login_params) do
      {
        document_type:,
        document_number:,
        postal_code:,
        access_code:,
        day: birthdate.day,
        month: birthdate.month,
        year: birthdate.year
      }
    end
    let(:login_params_changes) { {} }

    let(:valid_voter_id) { "a2a7ad82b9c8bf690436a64459265fe8c7fc9a87ec4283fbbd3cd9363e0b3824" }

    it { expect(subject.user).to be_nil }

    describe "#voter_id" do
      subject { vote_flow.voter_id }

      before { vote_flow.voter_login(login_params.merge(login_params_changes)) }

      it { is_expected.to eq(valid_voter_id) }

      {
        "dc5e5238cc86efe4473e175605736f961b9ee66d884185d9bba6e5587022fbe8" => { id: 10_001 },
        "dc20d11e54b4038c831152aaa5ff8226f4d5aada47c7072c97c8d5a6ef126254" => { created_at: Time.new(2000, 1, 1, 0, 0, 0, 1) }
      }.each do |voter_id, datum_changes|
        context "when changing the user data with #{datum_changes.to_json}" do
          let(:datum_params_changes) { datum_changes }

          it { is_expected.to eq(voter_id) }
        end
      end

      {
        "a6f5aa84746e3db6602dbb424906afa8a1fd6ef75c9730db4def0a9be4f0a2bb" => { id: 10_001 },
        "ae0b3634b86fdee34a49ef7fbc88021573f0419c8833e20fea40b85641282e02" => { created_at: Time.new(2000, 1, 1, 0, 0, 0, 1) },
        "93b5789b43fe5fbd1c2975137a4b01cf6988126de570e9d7ffd9c6be507c6c2f" => { salt: "ccef77cedb2d1269dd52466873cf5d7695365b91111e9adf08583cfe95e6c607" }
      }.each do |voter_id, election_changes|
        context "when changing the election data with #{election_changes.to_json}" do
          let(:election_params_changes) { election_changes }

          it { is_expected.to eq(voter_id) }
        end
      end
    end

    describe "#voter_id_token" do
      subject { vote_flow.voter_id_token(voter_id) }

      before { vote_flow.voter_login(login_params.merge(login_params_changes)) }

      let(:voter_id) { nil }

      it { is_expected.to eq("1af86ff1fb20cb203fd6") }

      context "when receiving a voter id" do
        let(:voter_id) { "2f222a608b5e43704bd7c22b8f582eeedb0cd64bc8b99a599d6028f3295ed90a" }

        it { is_expected.to eq("7137159cf614abe35d9a") }
      end
    end

    context "with time dependant validations" do
      around do |example|
        travel_to(now) { example.run }
      end

      let(:now) { Time.new(2000, 1, 1, 0, 0, 0, 0) }
      let(:valid_token) { "IBSjHn9uZObqElyMIc+8kDdyoyFSp7Sk5Hotc6miRSdmRHEUpEqtoWnHxAw1WPYMnWjFHdqvnlmSvhLJ6nFTUCFuUQ/BTSP/B8esCC+S12WIkpkbV2KVUt7POTjUefvbL0tL2TgDrpnjVa1iYuEhzUeMHbqTiy3skZ1hicc9G6HkWjKzj+PEVDbe9lZi1n2e7O3myZSYDdNvjfu7JaKQ5ghUP7pY1PDoqVgKq5nyonUwY1Y+dr82gM1Qtz8unxLmhoDg07GIH1bvw2oeAvhZQMdo9IuV8VckDr+8eEAfZ9ugVnxRHPx6P8XKry/TDeeADuhqfd62x7UiLjx3FRMIvqoMQAvJACwbWmWGP0zWtrS/zk9au0Vlj7kHmOmpAwT+rkQHGkyI+mWruv0ynniFqDm9R/CMJSmowpWwi1nExiLLhPNrl7EqP1GrVJSsZIczt0PNA3keTrsAqZPuyFStwdaGS9lKv1n+5WFHT/Pp2bLDNSpSdaD0I/72n99R--anVGgqjxutnUceeM--Pir5PKYxQ4DBfaQ1GAmGzg==" }
      let(:invalid_token) { "FBSjHn9uZObqElyMIc+8kDdyoyFSp7Sk5Hotc6miRSdmRHEUpEqtoWnHxAw1WPYMnWjFHdqvnlmSvhLJ6nFTUCFuUQ/BTSP/B8esCC+S12WIkpkbV2KVUt7POTjUefvbL0tL2TgDrpnjVa1iYuEhzUeMHbqTiy3skZ1hicc9G6HkWjKzj+PEVDbe9lZi1n2e7O3myZSYDdNvjfu7JaKQ5ghUP7pY1PDoqVgKq5nyonUwY1Y+dr82gM1Qtz8unxLmhoDg07GIH1bvw2oeAvhZQMdo9IuV8VckDr+8eEAfZ9ugVnxRHPx6P8XKry/TDeeADuhqfd62x7UiLjx3FRMIvqoMQAvJACwbWmWGP0zWtrS/zk9au0Vlj7kHmOmpAwT+rkQHGkyI+mWruv0ynniFqDm9R/CMJSmowpWwi1nExiLLhPNrl7EqP1GrVJSsZIczt0PNA3keTrsAqZPuyFStwdaGS9lKv1n+5WFHT/Pp2bLDNSpSdaD0I/72n99R--anVGgqjxutnUceeM--Pir5PKYxQ4DBfaQ1GAmGzg==" }

      context "when a voter token was not received" do
        it { expect(subject).not_to be_valid_received_data }

        it "generates a token with the token data" do
          generated_data = vote_flow.send(:message_encryptor).decrypt_and_verify(subject.voter_token)
          expect(generated_data).to eq(vote_flow.send(:voter_token_data).to_json)
        end
      end

      context "when a valid voter token was received" do
        before { vote_flow.voter_from_token(voter_token: valid_token, voter_id: valid_voter_id) }

        it { expect(subject).to have_voter }
        it { expect(subject).to be_valid_received_data }
        it { expect(subject.voter_token).to eq(valid_token) }

        context "when the voter token has expired" do
          let(:now) { Time.new(2000, 1, 1, 3, 0, 0, 0) }

          it { expect(subject).not_to have_voter }
          it { expect(subject).not_to be_valid_received_data }
          it { expect(subject.voter_token).to eq(valid_token) }
        end
      end

      context "when a wrong voter token was received" do
        before { vote_flow.voter_from_token(voter_token: invalid_token, voter_id: valid_voter_id) }

        it { expect(subject).not_to have_voter }
        it { expect(subject).not_to be_valid_received_data }
        it { expect(subject.voter_token).to eq(invalid_token) }
      end

      describe "datum based attributes and methods" do
        before { vote_flow.voter_from_token(voter_token: valid_token, voter_id: valid_voter_id) }

        it { expect(subject.email).to eq(datum.email) }
        it { expect(subject.voter_name).to eq(datum.full_name) }
        it { expect(subject.voter_data).to eq(id: datum.id, created: datum.created_at.to_i, name: datum.full_name) }
      end
    end

    context "when there is no datum for the given data" do
      let(:datum) { nil }

      it { expect(subject).not_to have_voter }
      it { expect(subject.email).to be_nil }
      it { expect(subject.voter_name).to be_nil }
      it { expect(subject.voter_data).to be_nil }
    end

    describe "#vote_check" do
      subject { vote_flow.vote_check }

      before { vote_flow.voter_login(login_params.merge(login_params_changes)) }

      it { expect(subject).to be_allowed }

      context "when the access code is invalid" do
        let(:login_params_changes) { { access_code: "an invalid code" } }

        it { expect(subject.error_message).to eq("The given data doesn't match any voter.") }
      end

      context "when the document type is invalid" do
        let(:login_params_changes) { { document_type: "Passport" } }

        it { expect(subject.error_message).to eq("The given data doesn't match any voter.") }
      end

      context "when the birthdate is invalid" do
        let(:login_params_changes) { { day: 15 } }

        it { expect(subject.error_message).to eq("The given data doesn't match any voter.") }
      end
    end

    describe "#login_path" do
      subject { vote_flow.login_path("a vote path") }

      it { expect(subject).to eq("/votings/#{voting.slug}/login?election_id=10000&vote_path=a+vote+path") }
    end

    describe "#questions_for" do
      subject { vote_flow.questions_for(election) }

      context "when the election has a ballot_style" do
        let(:datum_params_changes) { { ballot_style:, dataset: } }
        let(:ballot_style) { create(:ballot_style, :with_ballot_style_questions, election:, voting:) }

        it { expect(subject).to match_array(election.questions.first(2)) }
      end

      context "when the election does NOT have a ballot_style" do
        let(:datum_params_changes) { { dataset: } }

        it { expect(subject).to match_array(election.questions) }
      end
    end

    describe "#ballot_style_id" do
      subject { vote_flow.ballot_style_id }

      before { vote_flow.voter_login(login_params.merge(login_params_changes)) }

      context "when the election has a ballot_style" do
        let(:datum_params_changes) { { ballot_style:, dataset: } }
        let(:ballot_style) { create(:ballot_style, voting:) }

        it { expect(subject).to eq(ballot_style.slug) }
      end

      context "when the election does NOT have a ballot_style" do
        let(:datum_params_changes) { { dataset: } }

        it { expect(subject).to be_nil }
      end
    end
  end
end
