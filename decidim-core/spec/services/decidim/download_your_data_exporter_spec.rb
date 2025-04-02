# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/download_your_data_shared_examples"

module Decidim
  describe DownloadYourDataExporter do
    subject { DownloadYourDataExporter.new(user, "download-your-data", "CSV") }

    let(:user) { create(:user, organization:) }
    let(:organization) { create(:organization) }
    let(:expected_files) do
      # this are the prefixes for the files that could have user generated content
      %w(
        decidim-follows-
        decidim-identities-
        decidim-messaging-conversations-
        decidim-notifications-
        decidim-participatoryspaceprivateusers-
        decidim-reports-
        decidim-users-
        decidim-meetings-registrations-
        decidim-meetings-invites-
        decidim-meetings-meetings-
        decidim-proposals-proposals-
        decidim-budgets-orders-
        decidim-forms-responses-
        decidim-debates-debates-
        decidim-conferences-conferenceregistrations-
        decidim-conferences-conferenceinvites-
        decidim-comments-comments-
        decidim-comments-commentvotes-
        decidim-initiatives-initiatives-
      )
    end

    describe "#data_and_attachments_for_user" do
      it "returns an array of data for the user" do
        user_data, = subject.send(:data_and_attachments_for_user)

        file_prefixes = expected_files.dup
        user_data.each do |entity, exporter_data|
          entity_prefix = file_prefixes.find { |prefix| prefix.start_with?(entity) }
          expect(file_prefixes.delete(entity_prefix)).to be_present

          # we have an empty file  for each entity except for decidim-users
          expect(exporter_data.read).to eq("\n") unless entity == "decidim-users"
        end
        expect(file_prefixes).to be_empty
      end
    end

    describe "#readme" do
      describe "the user" do
        let(:help_definition_string) { "The username of the user" }

        it_behaves_like "a download your data entity"
      end

      context "when the user has a follow" do
        let!(:follow) { create(:follow, user:) }
        let(:help_definition_string) { "The resource or space that is being followed" }

        it_behaves_like "a download your data entity"
      end

      context "when the user has a notification" do
        let!(:notification) { create(:notification, user:) }
        let(:help_definition_string) { "The type of the resource that the notification is related to" }

        it_behaves_like "a download your data entity"
      end

      context "when the user has a conversation" do
        let!(:conversation) { create(:conversation, originator: user) }
        let!(:message) { create(:message, conversation:) }
        let(:help_definition_string) { "The messages of this conversation" }

        it_behaves_like "a download your data entity"
      end

      context "when the user has an identity" do
        let!(:identity) { create(:identity, user:) }
        let(:help_definition_string) { "The provider of this identity" }

        it_behaves_like "a download your data entity"
      end

      context "when the user has a report" do
        let(:moderation) { create(:moderation, reportable:, participatory_space:) }
        let(:participatory_space) { create(:participatory_process, organization:) }
        let(:reportable) { create(:proposal, component:) }
        let(:component) { create(:proposal_component, organization:) }
        let!(:report) { create(:report, moderation:, user:) }

        let(:help_definition_string) { "The reason of this report" }

        it_behaves_like "a download your data entity"
      end

      context "when the user has participatory_space_private_user" do
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user:) }
        let(:help_definition_string) { "The role that this private user has" }

        it_behaves_like "a download your data entity"
      end
    end
  end
end
