# frozen_string_literal: true

shared_examples "admin manages proposal answer imports" do
  before do
    click_on "Import"
    click_on "Import answers from a file"
  end

  describe "import answers from a file" do
    it "has start import button" do
      expect(page).to have_content("Import")
    end

    it "returns error without a file" do
      click_on "Import"
      expect(page).to have_content("There is an error in this field")
    end

    it "adds proposal answers after successfully import" do
      File.write(json_file, JSON.pretty_generate(answers))
      dynamically_attach_file(:import_file, json_file)

      expect(Decidim::Proposals::Admin::NotifyProposalAnswer).to receive(:call).exactly(amount).times

      click_on "Import"
      expect(page).to have_content("#{amount} proposal #{amount == 1 ? "answer" : "answers"} successfully imported")
      answers.each do |answer|
        proposal = Decidim::Proposals::Proposal.find(answer[:id])
        expect(proposal.state).to eq(answer[:state])
        expect(proposal.answer["en"]).to eq(answer[:"answer/en"])
        expect(proposal.answer["ca"]).to eq(answer[:"answer/ca"])
        expect(proposal.answer["es"]).to eq(answer[:"answer/es"])
      end
    end

    it "does not accept file without required headers" do
      File.write(json_file, JSON.pretty_generate(missing_answers))
      dynamically_attach_file(:import_file, json_file)
      click_on "Import"
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

      it "adds proposal answers after successfully import" do
        File.write(json_file, JSON.pretty_generate(answers))
        dynamically_attach_file(:import_file, json_file)

        expect(Decidim::Proposals::Admin::NotifyProposalAnswer).to receive(:call).exactly(amount).times

        click_on "Import"
        expect(page).to have_content("#{amount} proposal #{amount == 1 ? "answer" : "answers"} successfully imported")
        answers.each do |answer|
          proposal = Decidim::Proposals::Proposal.find(answer[:id])
          expect(proposal.state).to eq(answer[:state])
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

      click_on "Download example"
      expect(page).to have_content("Example as CSV")
      expect(page).to have_content("Example as JSON")
      expect(page).to have_content("Example as Excel (.xlsx)")
    end

    context "when downloading the examples" do
      before do
        click_on "Download example"
      end

      it "downloads a correct CSV example" do
        click_on "Example as CSV"

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
        click_on "Example as JSON"

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
        click_on "Example as Excel (.xlsx)"

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
