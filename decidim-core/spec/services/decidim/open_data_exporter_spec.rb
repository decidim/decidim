# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/open_data_exporter_examples"

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
          expect(csv_data).to include("Generated on #{Time.current.strftime("%d/%m/%Y")}")
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

    describe "with users" do
      let(:resource_file_name) { "users" }
      let(:resource_title) { "### users" }
      let!(:resource) { create(:user, :confirmed, organization:) }
      let!(:unpublished_resource) { create(:user, :confirmed, :blocked, organization:) }
      let(:help_lines) do
        [
          "* id: The unique identifier of the user",
          "* direct_messages_enabled: Whether the user allows direct messages"
        ]
      end

      it_behaves_like "open users data exporter"

      context "when user is deleted" do
        let!(:resource) { create(:user, :confirmed, :deleted, organization:) }

        it_behaves_like "open users data exporter"
      end
    end

    describe "with taxonomies" do
      let(:resource_file_name) { "taxonomies" }
      let(:resource_title) { "### taxonomies" }
      let!(:resource) { create(:taxonomy, organization:) }
      let(:help_lines) do
        [
          "* id: The unique identifier of this taxonomy",
          "* name: The name of this taxonomy"
        ]
      end

      include_examples "default open data exporter"

      it "includes the resource data" do
        expect(data).to include(resource.id.to_s)
        expect(data).to include(resource.weight.to_s)
      end
    end

    describe "with moderations" do
      let(:resource_file_name) { "moderations" }
      let(:resource_title) { "### moderations" }
      let!(:target_component) { create(:component, manifest_name: :dummy, organization:) }
      let!(:target_reportable) { create(:dummy_resource, component: target_component) }
      let!(:other_reportable) { create(:dummy_resource, component: target_component) }

      let!(:resource) { create(:moderation, reportable: target_reportable, hidden_at: Time.current) }
      let!(:unpublished_resource) { create(:moderation, reportable: other_reportable) }
      let(:help_lines) do
        [
          "* id: The unique identifier of the moderation",
          "* reported_content: The content that has been reported"
        ]
      end

      it_behaves_like "open moderation data exporter"
    end

    describe "with user moderations" do
      let(:resource_file_name) { "moderated_users" }
      let(:resource_title) { "### moderated_users" }
      let(:admin) { create(:user, :admin, organization:) }

      let(:user) { create(:user, :confirmed, organization:) }
      let!(:moderation) { create(:user_moderation, user:) }
      let(:user_report) { create(:user_report, moderation:, user: admin) }
      let!(:user_block) { create(:user_block, user:, blocking_user: admin) }

      let(:other_user) { create(:user, :confirmed, organization:) }
      let!(:other_moderation) { create(:user_moderation, user: other_user) }
      let(:other_user_report) { create(:user_report, moderation: other_moderation, user: admin) }

      let!(:unpublished_resource) { other_user.reload }
      let!(:resource) { user.reload }

      let(:help_lines) do
        [
          "* id: The unique identifier of the user",
          "* blocking_user: The name of the user that has performed the blocking"
        ]
      end

      it_behaves_like "open moderation data exporter"
    end

    describe "with all the components and spaces" do
      let(:proposal_component) { create(:proposal_component, organization:, published_at: Time.current) }
      let!(:proposals) { create_list(:proposal, 5, :published, component: proposal_component, title: { en: "My super proposal" }) }
      let(:proposal) { proposals.first }
      let!(:proposal_comment) { create(:comment, commentable: proposal) }
      let(:another_proposal_component) { create(:proposal_component, organization:, published_at: Time.current) }
      let!(:more_proposals) { create_list(:proposal, 10, :published, component: another_proposal_component, title: { en: "My super proposal" }) }

      let(:result_component) { create(:accountability_component, organization:, published_at: Time.current) }
      let!(:result) { create(:result, component: result_component) }

      let(:meeting_component) { create(:meeting_component, organization:, published_at: Time.current) }
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
          expect(file_data).to include("## users (15 resources)")
          expect(file_data).to include("## proposals (15 resources)")
          expect(file_data).to include("## proposal_comments (1 resource)")
          expect(file_data).to include("## results (1 resource)")
          expect(file_data).to include("## meetings (1 resource)")
          expect(file_data).to include("## meeting_comments (1 resource)")
          expect(file_data).to include("## participatory_processes (30 resources)")
          expect(file_data).to include("## assemblies (6 resources)")
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
