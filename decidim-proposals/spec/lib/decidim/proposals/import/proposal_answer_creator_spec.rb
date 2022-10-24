# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Import::ProposalAnswerCreator do
  subject { described_class.new(data, context) }

  let(:proposal) { create(:proposal, state:, component:) }
  let!(:moment) { Time.current }
  # rubocop:disable Style/HashSyntax
  let(:data) do
    {
      id: proposal.id,
      state: state,
      :"answer/en" => Faker::Lorem.paragraph
    }
  end
  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:user) { create(:user, organization: organization) }
  let(:context) do
    {
      current_organization: organization,
      current_user: user,
      current_component: component,
      current_participatory_space: participatory_process
    }
  end
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:component) { create :component, manifest_name: :proposals, participatory_space: participatory_process }
  let(:state) { %w(evaluating accepted rejected).sample }

  describe "#resource_klass" do
    it "returns the correct class" do
      expect(described_class.resource_klass).to be(Decidim::Proposals::Proposal)
    end
  end

  describe "#resource_attributes" do
    it "returns the attributes hash" do
      expect(subject.resource_attributes).to eq(
        id: data[:id],
        :"answer/en" => data[:"answer/en"],
        state: data[:state]
      )
    end
  end

  describe "#produce" do
    it "adds answer to proposal" do
      record = subject.produce

      expect(record).to be_a(Decidim::Proposals::Proposal)
      expect(record.id).to eq(data[:id])
      expect(record.answer["en"]).to eq(data[:"answer/en"])
      expect(record[:state]).to eq(data[:state])
      expect(record.answered_at).to be >= (moment)
    end

    context "with an emendation" do
      let!(:amendable) { create(:proposal, component: component) }
      let!(:amendment) { create(:amendment, amendable: amendable, emendation: proposal, state: "evaluating") }

      it "does not produce a record" do
        record = subject.produce

        expect(record).to be_nil
      end
    end
  end

  describe "#finish!" do
    it "saves the proposal" do
      record = subject.produce
      subject.finish!
      expect(record.new_record?).to be(false)
    end

    it "creates an admin log record" do
      record = subject.produce
      subject.finish!

      log = Decidim::ActionLog.last
      expect(log.resource).to eq(record)
      expect(log.action).to eq("answer")
    end
  end
  # rubocop:enable Style/HashSyntax
end
