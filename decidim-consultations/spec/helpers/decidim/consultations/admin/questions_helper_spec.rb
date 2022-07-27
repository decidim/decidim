# frozen_string_literal: true

require "spec_helper"

describe Decidim::Consultations::Admin::QuestionsHelper do
  describe "question_example_slug" do
    it "returns an example slug" do
      expect(helper.question_example_slug).to eq("question-#{Time.now.utc.year}-#{Time.now.utc.month}-1")
    end
  end

  describe "question_response_groups" do
    let(:question) { create :question }
    let(:group1) { create :response_group, question: }
    let(:group2) { create :response_group, question: }
    let(:group3) { create :response_group, question: }
    let!(:groups) do
      ["", group1.id, group2.id, group3.id]
    end

    it "returns an array of available groups" do
      expect(helper.question_response_groups(question).count).to eq(4)
      expect(helper.question_response_groups(question).pluck(:id)).to eq(groups)
    end
  end
end
