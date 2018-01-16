# frozen_string_literal: true
require "spec_helper"

describe Decidim::Debates::Admin::UpdateDebate do
  let(:debate) { create :debate }
  let(:organization) { debate.feature.organization }
  let(:category) { create :category, participatory_space: debate.feature.participatory_space }
  let(:form) do
    double(
      invalid?: invalid,
      title: { en: "title" },
      description: { en: "description" },
      instructions: { en: "instructions" },
      start_time: 1.day.from_now,
      end_time: 1.day.from_now + 1.hour,
      category: category
    )
  end
  let(:invalid) { false }

  subject { described_class.new(form, debate) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "updates the debate" do
      subject.call
      expect(translated(debate.title)).to eq "title"
    end

    it "sets the category" do
      subject.call
      expect(debate.category).to eq category
    end
  end
end
