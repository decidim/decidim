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

      describe "LICENSE.md" do
        let(:csv_file_name) { "LICENSE.md" }

        before do
          subject.export
        end

        it "includes a LICENSE" do
          expect(csv_file).not_to be_nil
        end

        it "includes the LICENSE content" do
          expect(csv_data).to include("License")
          expect(csv_data).to include("is made available under the Open Database License: http://opendatacommons.org/licenses/odbl/1.0/")
          expect(csv_data).to include("Database Contents License: http://opendatacommons.org/licenses/dbcl/1.0/")
        end
      end
    end

    describe "with all the components and spaces" do
      let(:proposal_component) do
        create(:proposal_component, organization:, published_at: Time.current)
      end
      let!(:proposal) { create(:proposal, :published, component: proposal_component, title: { en: "My super proposal" }) }
      let!(:proposal_comment) { create(:comment, commentable: proposal) }
      let(:result_component) do
        create(:accountability_component, organization:, published_at: Time.current)
      end
      let!(:result) { create(:result, component: result_component) }
      let(:meeting_component) do
        create(:meeting_component, organization:, published_at: Time.current)
      end
      let!(:meeting) { create(:meeting, :published, component: meeting_component) }
      let!(:meeting_comment) { create(:comment, commentable: meeting) }
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
          expect(file_data).to include("## proposal_comments")
          expect(file_data).to include("## results")
          expect(file_data).to include("## meetings")
          expect(file_data).to include("## meeting_comments")
          expect(file_data).to include("## participatory_process")
          expect(file_data).to include("## assemblies")
        end

        it "does not have any missing translation" do
          expect(file_data).not_to include("Translation missing")
        end
      end
    end

    describe "with a space" do
      subject { described_class.new(organization, path, resource) }

      let!(:assembly) { create(:assembly, :published, organization:) }
      let(:resource) { "assemblies" }
      let(:path) { "/tmp/test-open-data-assembly.csv" }

      it "generates a zip file at the path" do
        subject.export

        expect(File.exist?(path)).to be(true)
      end

      describe "contents" do
        let(:csv_data) { CSV.parse(File.read(path), headers: true, col_sep: ";") }

        describe "test-open-data-assembly.csv" do
          before do
            subject.export
          end

          it "includes a CSV file" do
            expect(csv_data).not_to be_nil
          end

          it "includes the resource's content" do
            expect(csv_data.headers).to include("id")
            expect(csv_data.headers).to include("title/en")
            expect(csv_data.first["id"]).to eq(assembly.id.to_s)
            expect(csv_data.first["title/en"]).to eq(translated_attribute(assembly.title["en"]))
          end
        end
      end
    end

    describe "with a component" do
      subject { described_class.new(organization, path, resource) }

      let(:proposal_component) do
        create(:proposal_component, organization:, published_at: Time.current)
      end
      let!(:proposal) { create(:proposal, :published, component: proposal_component, title: { en: "My super proposal" }) }
      let(:resource) { "proposals" }
      let(:path) { "/tmp/test-open-data-proposals.csv" }

      it "generates a zip file at the path" do
        subject.export

        expect(File.exist?(path)).to be(true)
      end

      describe "contents" do
        let(:csv_data) { CSV.parse(File.read(path), headers: true, col_sep: ";") }

        describe "test-open-data-proposals.csv" do
          before do
            subject.export
          end

          it "includes a CSV file" do
            expect(csv_data).not_to be_nil
          end

          it "includes the resource's content" do
            expect(csv_data.headers).to include("id")
            expect(csv_data.headers).to include("title/en")
            expect(csv_data.first["id"]).to eq(proposal.id.to_s)
            expect(csv_data.first["title/en"]).to eq(translated_attribute(proposal.title["en"]))
          end
        end
      end
    end
  end
end
