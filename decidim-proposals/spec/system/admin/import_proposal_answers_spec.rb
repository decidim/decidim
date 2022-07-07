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
      expect(page).to have_content("There's an error in this field")
    end

    it "adds proposal answers after succesfully import" do
      File.write(json_file, JSON.pretty_generate(answers))
      dynamically_attach_file(:import_file, json_file)

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

    it "doesnt accept file without required headers" do
      File.write(json_file, JSON.pretty_generate(missing_answers))
      dynamically_attach_file(:import_file, json_file)
      click_button "Import"
      expect(page).to have_content("Missing column answer/en. Please check that the file contains required columns.")
    end

    context "with nested JSON" do
      let(:answers) do
        proposals.map do |proposal|
          {
            id: proposal.id,
            state: %w(accepted rejected evaluating).sample,
            answer: {
              en: Faker::Lorem.sentence,
              ca: Faker::Lorem.sentence,
              es: Faker::Lorem.sentence
            }
          }
        end
      end

      it "adds proposal answers after succesfully import" do
        File.write(json_file, JSON.pretty_generate(answers))
        dynamically_attach_file(:import_file, json_file)

        expect(Decidim::Proposals::Admin::NotifyProposalAnswer).to receive(:call).exactly(amount).times

        click_button "Import"
        expect(page).to have_content("#{amount} proposal #{amount == 1 ? "answer" : "answers"} successfully imported")
        answers.each do |answer|
          proposal = Decidim::Proposals::Proposal.find(answer[:id])
          expect(proposal[:state]).to eq(answer[:state])
          expect(proposal.answer["en"]).to eq(answer[:answer][:en])
          expect(proposal.answer["ca"]).to eq(answer[:answer][:ca])
          expect(proposal.answer["es"]).to eq(answer[:answer][:es])
        end
      end
    end
  end

  describe "download examples", download: true do
    it "provides example downloads" do
      expect(page).to have_content("Download example")

      page.find(".imports-example").click
      expect(page).to have_content("Example as CSV")
      expect(page).to have_content("Example as JSON")
      expect(page).to have_content("Example as Excel (.xlsx)")
    end

    context "when downloading the examples" do
      before do
        page.find(".imports-example").click
      end

      it "downloads a correct CSV example" do
        click_link "Example as CSV"

        expect(File.basename(download_path)).to eq("proposals-answers-example.csv")
        expect(File.read(download_path)).to eq(
          <<~CSV
            id;state;answer/en;answer/ca;answer/es
            1;accepted;Example answer;Example answer;Example answer
            2;rejected;Example answer;Example answer;Example answer
            3;evaluating;Example answer;Example answer;Example answer
          CSV
        )
      end

      it "downloads a correct JSON example" do
        click_link "Example as JSON"

        expect(File.basename(download_path)).to eq("proposals-answers-example.json")
        expect(File.read(download_path)).to eq(
          <<~JSON.strip
            [
              {
                "id": 1,
                "state": "accepted",
                "answer": {
                  "en": "Example answer",
                  "ca": "Example answer",
                  "es": "Example answer"
                }
              },
              {
                "id": 2,
                "state": "rejected",
                "answer": {
                  "en": "Example answer",
                  "ca": "Example answer",
                  "es": "Example answer"
                }
              },
              {
                "id": 3,
                "state": "evaluating",
                "answer": {
                  "en": "Example answer",
                  "ca": "Example answer",
                  "es": "Example answer"
                }
              }
            ]
          JSON
        )
      end

      it "downloads a correct XLSX example" do
        click_link "Example as Excel (.xlsx)"

        expect(File.basename(download_path)).to eq("proposals-answers-example.xlsx")

        # The generated XLSX can have some byte differences which is why we need
        # to read the values from both files and compare them instead.
        workbook = RubyXL::Parser.parse(download_path)
        actual = workbook.worksheets[0].map { |row| row.cells.map(&:value) }

        expect(actual).to eq(
          [
            %w(id state answer/en answer/ca answer/es),
            [1, "accepted", "Example answer", "Example answer", "Example answer"],
            [2, "rejected", "Example answer", "Example answer", "Example answer"],
            [3, "evaluating", "Example answer", "Example answer", "Example answer"]
          ]
        )
      end
    end
  end
end
