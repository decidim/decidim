# frozen_string_literal: true

require "spec_helper"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  let(:organization) { create(:organization) }
  let(:path) { "/tmp/test-open-data.zip" }

  describe "export" do
    it "generates a zip file at the path" do
      subject.export

      expect(File.exist?(path)).to be(true)
    end

    describe "contents" do
      let(:zip_contents) { Zip::File.open(path) }
      let(:csv_file) { zip_contents.glob(csv_file_name).first }
      let(:csv_data) { csv_file.get_input_stream.read }

      describe "initiatives" do
        let(:csv_file_name) { "*open-data-initiatives.csv" }
        let!(:initiative) { create(:initiative, :open, organization:) }

        before do
          subject.export
        end

        it "includes a CSV with initiatives" do
          expect(csv_file).not_to be_nil
        end

        it "includes the initiatives data" do
          expect(csv_data).to include(initiative.title["en"].gsub(/"/, '""'))
        end

        describe "README content" do
          let(:csv_file_name) { "README.md" }

          it "includes the initiatives help description" do
            expect(csv_data).to include("## initiatives")
            expect(csv_data).to include("* reference: The reference of the initiative. An unique identifier for this platform.")
          end

          it "does not have any missing translation" do
            expect(csv_data).not_to include("Translation missing")
          end
        end

        context "with an unpublished initiative" do
          let!(:initiative) { create(:initiative, :created, organization:) }

          it "does not include the initiatives data" do
            expect(csv_data).not_to include(initiative.title["en"])
          end
        end
      end
    end
  end
end
