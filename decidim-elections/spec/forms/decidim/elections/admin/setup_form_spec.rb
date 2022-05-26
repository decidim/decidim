# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::SetupForm do
  subject(:form) { described_class.from_params(attributes).with_context(context) }

  let(:context) do
    {
      current_organization: component.organization,
      current_component: component,
      election: election,
      current_step: "create_election"
    }
  end
  let(:election) { create :election, :ready_for_setup, trustee_keys: [] }
  let(:component) { election.component }
  let(:attributes) do
    {
      setup: {
        trustee_ids: trustee_ids
      }
    }
  end
  let!(:trustees) { create_list :trustee, 5, :with_public_key, election: election }
  let(:trustee_ids) { trustees.pluck(:id) }

  it { is_expected.to be_valid }

  it "shows messages" do
    expect(subject.messages).to match(
      hash_including({
                       max_selections: "All the questions have a correct value for <strong>maximum of answers</strong>.",
                       minimum_answers: "Each question has <strong>at least 2 answers</strong>.",
                       minimum_questions: "The election has <strong>at least 1 question</strong>.",
                       published: "The election is <strong>published</strong>.",
                       time_before: "The setup is being done <strong>at least 3 hours</strong> before the election starts.",
                       trustees_number: "The participatory space has <strong>at least 3 trustees with public key</strong>."
                     })
    )
  end

  context "when the election is not ready for the setup" do
    let(:election) { create :election }

    it { is_expected.to be_invalid }

    it "shows errors" do
      subject.valid?
      expect(subject.errors.messages).to eq({
                                              minimum_questions: ["The election <strong>must have at least one question</strong>."],
                                              published: ["The election is <strong>not published</strong>."]
                                            })
    end
  end

  context "when validating the census" do
    let(:election) { create :election }

    context "when the participatory space is not a voting" do
      it "does not add errors about the census" do
        expect(subject.errors.messages[:census_not_frozen]).to be_empty
      end
    end

    context "when the participatory space is a voting" do
      let(:election) { create :voting_election }
      let(:dataset) { create :dataset, voting: election.participatory_space, status: census_status }

      context "when the census is not frozen" do
        let(:census_status) { "init_data" }

        it { is_expected.to be_invalid }

        it "shows errors" do
          subject.valid?
          expect(subject.errors.messages).to match(hash_including({ census_not_frozen: ["The census for this election must be frozen before creating the election"] }))
        end
      end

      context "when the census is frozen" do
        let(:census_status) { "freeze" }

        it "does not add errors about the census" do
          expect(subject.errors.messages[:census_not_frozen]).to be_empty
        end
      end
    end
  end

  context "when there are no trustees for the election" do
    let(:trustees) { [] }

    it { is_expected.to be_invalid }

    it "shows errors" do
      subject.valid?
      expect(subject.errors.messages).to eq({
                                              trustees_number: ["The participatory space <strong>must have at least 3 trustees with public key</strong>."]
                                            })
    end
  end

  context "when the trustee_ids are not initialized" do
    let(:attributes) { {} }

    it { is_expected.to be_valid }

    it "choose random trustees" do
      expect(subject.trustees).to be_any
    end
  end

  describe ".participatory_space_trustees" do
    subject { form.participatory_space_trustees.pluck(:id) }

    let!(:other_trustees) { create_list :trustee, 3, :with_public_key }

    it { is_expected.to match_array(trustees.pluck(:id)) }
  end
end
