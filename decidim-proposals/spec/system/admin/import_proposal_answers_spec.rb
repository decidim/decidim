# frozen_string_literal: true

require "spec_helper"

describe "Import proposal answers", type: :system do
  let(:organization) { create(:organization, available_locales: [:en, :ca, :es]) }
  let(:component) { create(:proposal_component, organization:) }
  let(:proposals) { create_list(:proposal, amount, component:) }

  let(:manifest_name) { "proposals" }
  let(:participatory_space) { component.participatory_space }
  let(:user) { create(:user, organization:) }

  let(:answers) do
    proposals.map do |proposal|
      {
        id: proposal.id,
        state: %w(accepted rejected evaluating).sample,
        "answer/en": Faker::Lorem.sentence,
        "answer/ca": Faker::Lorem.sentence,
        "answer/es": Faker::Lorem.sentence
      }
    end
  end

  let(:missing_answers) do
    proposals.map do |proposal|
      {
        id: proposal.id,
        state: %w(accepted rejected evaluating).sample,
        "answer/fi": Faker::Lorem.sentence,
        hello: "world"
      }
    end
  end

  let(:amount) { rand(1..5) }
  let(:json_file) { Rails.root.join("tmp/import_proposal_answers.json") }

  include_context "when managing a component as an admin"

  it_behaves_like "admin manages proposal answer imports"

  context "with the votings space" do
    let(:participatory_space) { create(:voting, organization:) }
    let(:component) { create(:proposal_component, participatory_space:, organization:) }

    it_behaves_like "admin manages proposal answer imports"
  end
end
