# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::AnswerForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:context) do
    {
      current_organization: component.organization,
      current_component: component,
      election:,
      question:
    }
  end
  let(:election) { question.election }
  let(:question) { create :question }
  let(:component) { election.component }
  let(:title) { Decidim::Faker::Localized.sentence(word_count: 3) }
  let(:description) { Decidim::Faker::Localized.sentence(word_count: 3) }
  let(:weight) { 10 }
  let(:attachment_params) { nil }
  let(:attributes) do
    {
      title:,
      description:,
      weight:,
      attachment: attachment_params
    }
  end

  it { is_expected.to be_valid }

  describe "when title is missing" do
    let(:title) { { ca: nil, es: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when description is missing" do
    let(:description) { { ca: nil, es: nil } }

    it { is_expected.to be_valid }
  end

  context "when the attachment is present" do
    let(:attachment_params) do
      {
        title: "My attachment",
        file: Decidim::Dev.test_file("city.jpeg", "image/jpeg")
      }
    end

    it { is_expected.to be_valid }

    context "when the form has some errors" do
      let(:title) { { ca: nil, es: nil } }

      it "adds an error to the `:attachment` field" do
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(["Title en can't be blank", "Attachment Needs to be reattached"])
        expect(subject.errors.attribute_names).to match_array([:title_en, :attachment])
      end
    end
  end

  context "with proposals" do
    subject { described_class.from_model(answer).with_context(context) }

    let(:proposals_component) { create :component, manifest_name: :proposals, participatory_space: component.participatory_space }
    let(:proposals) { create_list :proposal, 2, component: proposals_component }
    let(:answer) { create :election_answer, question: }

    describe "#map_model" do
      it "sets the proposal_ids correctly" do
        answer.link_resources(proposals, "related_proposals")
        expect(subject.proposal_ids).to match_array(proposals.map(&:id))
      end
    end

    describe "#proposals" do
      before { answer.link_resources(proposals, "related_proposals") }

      it "returns the available proposals in a way suitable for the form" do
        expect(subject.proposals).to match_array(proposals)
      end
    end
  end
end
