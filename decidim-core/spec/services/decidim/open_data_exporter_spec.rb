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
        end
      end
    end

    describe "with moderations" do
      let(:resource_file_name) { "moderations" }
      let(:resource_title) { "### moderations" }
      let!(:target_component) { create(:component, manifest_name: :dummy, organization:) }
      let!(:target_reportable) { create(:dummy_resource, component: target_component) }
      let!(:other_reportable) { create(:dummy_resource, component: target_component) }

      let!(:resource) { create(:moderation, reportable: target_reportable, hidden_at: Time.current) }
      let!(:unpublished_resource) { create(:moderation, reportable: other_reportable, hidden_at: Time.current) }
      let(:help_lines) do
        [
          "* id: The unique identifier of the moderation",
          "* reported_content: The content that has been reported"
        ]
      end

      it_behaves_like "open data exporter"
    end

    describe "with user moderations" do
      let(:resource_file_name) { "moderated_users" }
      let(:resource_title) { "### moderated_users" }
      let(:admin) { create(:user, :admin, organization:) }

      let(:user) { create(:user, :confirmed, organization:) }
      let(:other_user) { create(:user, :confirmed, organization:) }

      let!(:moderation) { create(:user_moderation, user:) }
      let!(:other_moderation) { create(:user_moderation, user: other_user) }

      let(:user_report) { create(:user_report, moderation:, user: admin) }
      let(:other_user_report) { create(:user_report, moderation: other_moderation, user: admin) }

      let!(:user_block) { create(:user_block, user:, blocking_user: admin) }

      let!(:unpublished_resource) { other_moderation }
      let!(:resource) { moderation }

      let(:help_lines) do
        [
          "* id: The unique identifier of the user",
          "* blocking_user: The name of the user that has performed the blocking"
        ]
      end

      it_behaves_like "open data exporter"
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

      it_behaves_like "open data exporter"
    end

    describe "with user groups" do
      let(:resource_file_name) { "users_groups" }
      let(:resource_title) { "### user_groups" }
      let!(:resource) { create(:user_group, :confirmed, organization:) }
      let!(:unpublished_resource) { create(:user_group, :confirmed, :blocked, organization:) }
      let(:help_lines) do
        [
          "* id: The unique identifier of the user",
          "* members_count: The number of the users belonging to the user group"
        ]
      end

      it_behaves_like "open data exporter"
    end

    describe "with all the components and spaces" do
      let!(:user_group) { create(:user_group, :confirmed, organization:) }
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
          expect(file_data).to include("## users")
          expect(file_data).to include("## user_groups")
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
  end
end
