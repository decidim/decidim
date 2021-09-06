# frozen_string_literal: true

require "spec_helper"

describe "Import proposal answers", type: :system do
  let(:organization) { create(:organization, available_locales: [:en, :ca, :es]) }
  let(:component) { create(:proposal_component, organization: organization) }
  let(:proposals) { create_list(:proposal, amount, component: component) }

  let(:manifest_name) { "proposals" }
  let(:participatory_space) { component.participatory_space }
  let(:user) { create :user, organization: organization }

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

  let(:invalid_answers) do
    proposals.map do |proposal|
      {
        id: proposal.id,
        state: %w(accepted rejected evaluating).sample,
        "answer/fi": Faker::Lorem.sentence,
        "hello": "world"
      }
    end
  end

  let(:amount) { rand(1..5) }
  let(:json_file) { Rails.root.join("tmp/import_proposal_answers.json") }

  include_context "when managing a component as an admin"

  before do
    page.find(".imports").click
    click_link "Import answers from a file"
  end

  describe "import answers from a file" do
    it "has start import button" do
      expect(page).to have_content("Import")
    end

    it "returns error without a file" do
      click_button "Import"
      expect(page).to have_content("There was a problem during the import")
    end

    it "adds proposal answers after succesfully import" do
      File.open(json_file, "w") do |f|
        f.write(JSON.pretty_generate(answers))
      end
      attach_file :import_file, json_file

      expect(Decidim::Proposals::Admin::NotifyProposalAnswer).to receive(:call).exactly(amount).times

      click_button "Import"
      expect(page).to have_content("#{amount} proposal #{amount == 1 ? "answer" : "answers"} successfully imported")
      answers.each do |answer|
        proposal = Decidim::Proposals::Proposal.find(answer[:id])
        expect(proposal[:state]).to eq(answer[:state])
        expect(proposal.answer["en"]).to eq(answer[:"answer/en"])
        expect(proposal.answer["ca"]).to eq(answer[:"answer/ca"])
        expect(proposal.answer["es"]).to eq(answer[:"answer/es"])
      end
    end

    it "doesnt accept file containing invalid headers" do
      File.open(json_file, "w") do |f|
        f.write(JSON.pretty_generate(invalid_answers))
      end
      attach_file :import_file, json_file
      click_button "Import"
      expect(page).to have_content("Found error in import file in column headers answer/fi and hello. Please check that these columns are formatted correctly and contain valid headers.")
    end
  end
end
