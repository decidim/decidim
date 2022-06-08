# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::QuestionForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:context) do
    {
      current_organization: component.organization,
      current_component: component,
      election: election
    }
  end
  let(:election) { create :election }
  let(:component) { election.component }
  let(:title) { Decidim::Faker::Localized.sentence(word_count: 3) }
  let(:max_selections) { 3 }
  let(:weight) { 10 }
  let(:random_answers_order) { true }
  let(:min_selections) { 1 }
  let(:attributes) do
    {
      title: title,
      max_selections: max_selections,
      min_selections: min_selections,
      weight: weight,
      random_answers_order: random_answers_order
    }
  end

  it { is_expected.to be_valid }

  describe "when title is missing" do
    let(:title) { { ca: nil, es: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when max_selections is missing" do
    let(:max_selections) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when max_selections is negative" do
    let(:max_selections) { -1 }

    it { is_expected.not_to be_valid }
  end

  describe "when max_selections is zero" do
    let(:max_selections) { 0 }

    it { is_expected.not_to be_valid }
  end
end
