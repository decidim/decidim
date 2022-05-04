# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::UpdateAnswerSelection do
  subject(:command) { described_class.new(answer, selected) }

  let(:election) { create(:election, :published, :results_published) }
  let(:question) { election.questions.first }
  let(:answer) { question.answers.first }
  let(:selected) { false }

  it "updates the selected answer attribute" do
    subject.call
    expect(answer.selected).to be(false)
  end

  context "when answer has no votes" do
    let(:answer) { create :election_answer }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
