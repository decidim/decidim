# frozen_string_literal: true

require "spec_helper"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  let(:organization) { create :organization }
  let(:path) { "/tmp/test-open-data.zip" }

  describe "export" do
    it "generates a zip file at the path" do
      subject.export

      expect(File.exist?(path)).to eq(true)
    end

    describe "contents" do
      let(:zip_contents) { Zip::File.open(path) }
      let(:csv_file) { zip_contents.glob(csv_file_name).first }
      let(:csv_data) { csv_file.get_input_stream.read }

      describe "proposals" do
        let(:csv_file_name) { "*open-data-proposals.csv" }
        let(:component) do
          create(:proposal_component, organization: organization, published_at: Time.current)
        end
        let!(:proposal) { create(:proposal, :published, component: component, title: "My super proposal") }

        before do
          subject.export
        end

        it "includes a CSV with proposals" do
          expect(csv_file).not_to be_nil
        end

        it "includes the proposals data" do
          expect(csv_data).to include(translated(proposal.title))
        end

        context "with unpublished components" do
          let(:component) do
            create(:proposal_component, organization: organization, published_at: nil)
          end

          it "includes the proposals data" do
            expect(csv_data).not_to include(translated(proposal.title))
          end
        end
      end

      describe "results" do
        let(:csv_file_name) { "*open-data-results.csv" }
        let(:component) do
          create(:accountability_component, organization: organization, published_at: Time.current)
        end
        let!(:result) { create(:result, component: component) }

        before do
          subject.export
        end

        it "includes a CSV with results" do
          expect(csv_file).not_to be_nil
        end

        it "includes the results data" do
          expect(csv_data).to include(result.title["en"])
        end

        context "with unpublished components" do
          let(:component) do
            create(:accountability_component, organization: organization, published_at: nil)
          end

          it "includes the results data" do
            expect(csv_data).not_to include(result.title["en"])
          end
        end
      end

      describe "meetings" do
        let(:csv_file_name) { "*open-data-meetings.csv" }
        let(:component) do
          create(:meeting_component, organization: organization, published_at: Time.current)
        end
        let!(:meeting) { create(:meeting, component: component) }

        before do
          subject.export
        end

        it "includes a CSV with meetings" do
          expect(csv_file).not_to be_nil
        end

        it "includes the meetings data" do
          expect(csv_data).to include(meeting.title["en"])
        end

        context "with unpublished components" do
          let(:component) do
            create(:meeting_component, organization: organization, published_at: nil)
          end

          it "includes the meetings data" do
            expect(csv_data).not_to include(meeting.title["en"])
          end
        end
      end
    end
  end
end
