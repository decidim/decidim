# frozen_string_literal: true

require "spec_helper"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  let(:organization) { create(:organization) }
  let(:path) { "/tmp/test-open-data.zip" }
  let(:zip_contents) { Zip::File.open(path) }

  describe "export" do
    it "generates a zip file at the path" do
      subject.export

      expect(File.exist?(path)).to be(true)
    end

    describe "contents" do
      let(:csv_file) { zip_contents.glob(csv_file_name).first }
      let(:csv_data) { csv_file.get_input_stream.read }

      describe "README.md" do
        let(:csv_file_name) { "README.md" }

        before do
          subject.export
        end

        it "includes a README" do
          expect(csv_file).not_to be_nil
        end

        it "includes the README content" do
          expect(csv_data).to include("# Open Data files for #{organization.name[:en]}")
          expect(csv_data).to include("This ZIP file contains files for studying and researching about this participation platform.")
        end
      end

      describe "proposals" do
        let(:csv_file_name) { "*open-data-proposals.csv" }
        let(:component) do
          create(:proposal_component, organization:, published_at: Time.current)
        end
        let!(:proposal) { create(:proposal, :published, component:, title: { en: "My super proposal" }) }

        before do
          subject.export
        end

        it "includes a CSV with proposals" do
          expect(csv_file).not_to be_nil
        end

        it "includes the proposals data" do
          expect(csv_data).to include(translated(proposal.title))
        end

        describe "README content" do
          let(:csv_file_name) { "README.md" }

          it "includes the proposals help description" do
            expect(csv_data).to include("## proposals")
            expect(csv_data).to include("* id: The unique identifier for the proposal")
          end

          it "does not have any missing translation" do
            expect(csv_data).not_to include("Translation missing")
          end
        end

        context "with unpublished components" do
          let(:component) do
            create(:proposal_component, organization:, published_at: nil)
          end

          it "does not include the proposals data" do
            expect(csv_data).not_to include(translated(proposal.title))
          end
        end
      end

      describe "results" do
        let(:csv_file_name) { "*open-data-results.csv" }
        let(:component) do
          create(:accountability_component, organization:, published_at: Time.current)
        end
        let!(:result) { create(:result, component:) }

        before do
          subject.export
        end

        it "includes a CSV with results" do
          expect(csv_file).not_to be_nil
        end

        it "includes the results data" do
          expect(csv_data).to include(translated(result.title).gsub("\"", "\"\""))
        end

        describe "README content" do
          let(:csv_file_name) { "README.md" }

          it "includes the results help description" do
            expect(csv_data).to include("## accountability")
            expect(csv_data).to include("* id: The unique identifier of the result")
          end

          it "does not have any missing translation" do
            expect(csv_data).not_to include("Translation missing")
          end
        end

        context "with unpublished components" do
          let(:component) do
            create(:accountability_component, organization:, published_at: nil)
          end

          it "does not include the results data" do
            expect(csv_data).not_to include(translated(result.title).gsub("\"", "\"\""))
          end
        end
      end

      describe "meetings" do
        let(:csv_file_name) { "*open-data-meetings.csv" }
        let(:component) do
          create(:meeting_component, organization:, published_at: Time.current)
        end
        let!(:meeting) { create(:meeting, :published, component:) }

        before do
          subject.export
        end

        it "includes a CSV with meetings" do
          expect(csv_file).not_to be_nil
        end

        it "includes the meetings data" do
          expect(csv_data).to include(meeting.title["en"].gsub(/"/, '""'))
        end

        describe "README content" do
          let(:csv_file_name) { "README.md" }

          it "includes the meeting help description" do
            expect(csv_data).to include("## meetings")
            expect(csv_data).to include("* id: The unique identifier of the meeting")
          end

          it "does not have any missing translation" do
            expect(csv_data).not_to include("Translation missing")
          end
        end

        context "with unpublished components" do
          let(:component) do
            create(:meeting_component, organization:, published_at: nil)
          end

          it "does not include the meetings data" do
            expect(csv_data).not_to include(meeting.title["en"])
          end
        end
      end

      describe "participatory processes" do
        let(:csv_file_name) { "*open-data-participatory_processes.csv" }
        let!(:participatory_process) { create(:participatory_process, :published, organization:) }

        before do
          subject.export
        end

        it "includes a CSV with participatory processes" do
          expect(csv_file).not_to be_nil
        end

        it "includes the participatory processes data" do
          expect(csv_data).to include(participatory_process.title["en"].gsub(/"/, '""'))
        end

        describe "README content" do
          let(:csv_file_name) { "README.md" }

          it "includes the participatory processes help description" do
            expect(csv_data).to include("## participatory_process")
            expect(csv_data).to include("* id: The unique identifier of this process")
          end

          it "does not have any missing translation" do
            expect(csv_data).not_to include("Translation missing")
          end
        end

        context "with unpublished participatory process" do
          let!(:participatory_process) { create(:participatory_process, :unpublished, organization:) }

          it "does not include the participatory process data" do
            expect(csv_data).not_to include(participatory_process.title["en"])
          end
        end
      end

      describe "assemblies" do
        let(:csv_file_name) { "*open-data-assemblies.csv" }
        let!(:assembly) { create(:assembly, :published, organization:) }

        before do
          subject.export
        end

        it "includes a CSV with assemblies" do
          expect(csv_file).not_to be_nil
        end

        it "includes the assemblies data" do
          expect(csv_data).to include(assembly.title["en"].gsub(/"/, '""'))
        end

        describe "README content" do
          let(:csv_file_name) { "README.md" }

          it "includes the assemblies help description" do
            expect(csv_data).to include("## assemblies")
            expect(csv_data).to include("* id: The unique identifier of this assembly")
          end

          it "does not have any missing translation" do
            expect(csv_data).not_to include("Translation missing")
          end
        end

        context "with unpublished assembly" do
          let!(:assembly) { create(:assembly, :unpublished, organization:) }

          it "does not include the assemblies data" do
            expect(csv_data).not_to include(assembly.title["en"])
          end
        end
      end
    end

    describe "with all the components and spaces" do
      let(:proposal_component) do
        create(:proposal_component, organization:, published_at: Time.current)
      end
      let!(:proposal) { create(:proposal, :published, component: proposal_component, title: { en: "My super proposal" }) }
      let(:result_component) do
        create(:accountability_component, organization:, published_at: Time.current)
      end
      let!(:result) { create(:result, component: result_component) }
      let(:meeting_component) do
        create(:meeting_component, organization:, published_at: Time.current)
      end
      let!(:meeting) { create(:meeting, :published, component: meeting_component) }
      let!(:participatory_process) { create(:participatory_process, :published, organization:) }
      let!(:assembly) { create(:assembly, :published, organization:) }

      before do
        subject.export
      end

      it "includes all the data" do
        {
          proposals: proposal,
          results: result,
          meetings: meeting,
          participatory_processes: participatory_process,
          assemblies: assembly
        }.each do |entity_name, entity|
          csv_data = zip_contents.glob("*open-data-#{entity_name}.csv").first.get_input_stream.read
          expect(csv_data).to include(entity.title["en"].gsub(/"/, '""'))
        end
      end

      describe "README content" do
        let(:file_data) { zip_contents.glob("README.md").first.get_input_stream.read }

        it "includes the help description for all the entities" do
          expect(file_data).to include("## proposals")
          expect(file_data).to include("## accountability")
          expect(file_data).to include("## meetings")
          expect(file_data).to include("## participatory_process")
          expect(file_data).to include("## assemblies")
        end

        it "does not have any missing translation" do
          expect(file_data).not_to include("Translation missing")
        end
      end
    end
  end
end
