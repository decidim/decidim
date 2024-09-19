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

      describe "conferences" do
        let(:csv_file_name) { "*open-data-conferences.csv" }
        let!(:conference) { create(:conference, :published, organization:) }

        before do
          subject.export
        end

        it "includes a CSV with conferences" do
          expect(csv_file).not_to be_nil
        end

        it "includes the conferences data" do
          expect(csv_data).to include(conference.title["en"].gsub(/"/, '""'))
        end

        describe "README content" do
          let(:csv_file_name) { "README.md" }

          it "includes the conferences help description" do
            expect(csv_data).to include("## conferences")
            expect(csv_data).to include("* id: The unique identifier of this conference")
          end

          it "does not have any missing translation" do
            expect(csv_data).not_to include("Translation missing")
          end
        end

        context "with unpublished conference" do
          let!(:conference) { create(:conference, :unpublished, organization:) }

          it "does not include the conferences data" do
            expect(csv_data).not_to include(conference.title["en"])
          end
        end
      end
    end
  end
end
