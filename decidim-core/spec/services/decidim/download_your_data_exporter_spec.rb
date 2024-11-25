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
        decidim-usergroups-
        decidim-meetings-registrations-
        decidim-proposals-proposals-
        decidim-budgets-orders-
        decidim-forms-answers-
        decidim-debates-debates-
        decidim-conferences-conferenceregistrations-
        decidim-conferences-conferenceinvites-
        decidim-comments-comments-
        decidim-comments-commentvotes-
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

      context "when the user has a comment" do
        let(:participatory_space) { create(:participatory_process, organization:) }
        let(:component) { create(:component, participatory_space:) }
        let(:commentable) { create(:dummy_resource, component:) }

        let!(:comment) { create(:comment, commentable:, author: user) }

        it "returns the comment data" do
          user_data, = subject.send(:data_and_attachments_for_user)

          user_data.find { |entity, _| entity == "decidim-comments-comments" }.tap do |_, exporter_data|
            csv_comments = exporter_data.read.split("\n")
            expect(csv_comments.count).to eq 2
            expect(csv_comments.first).to start_with "id;created_at;body;locale;author/id;author/name;alignment;depth;"
            expect(csv_comments.second).to start_with "#{comment.id};"
          end
        end
      end
    end

    describe "#readme" do
      describe "the user" do
        let(:help_definition_string) { "The username of the user" }

        it_behaves_like "a download your data entity"
      end

      context "when the user has a user group" do
        let!(:user_group) { create(:user_group, users: [user]) }
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

      context "when the user has a comment" do
        let(:participatory_space) { create(:participatory_process, organization:) }
        let(:component) { create(:component, participatory_space:) }
        let(:commentable) { create(:dummy_resource, component:) }
        let!(:comment) { create(:comment, commentable:, author: user) }
        let(:help_definition_string) { "If this comment was a favour, against or neutral" }

        it_behaves_like "a download your data entity"
      end

      context "when the user has a comment vote" do
        let(:participatory_space) { create(:participatory_process, organization:) }
        let(:component) { create(:component, participatory_space:) }
        let(:commentable) { create(:dummy_resource, component:) }
        let!(:comment) { create(:comment, commentable:) }
        let!(:comment_vote) { create(:comment_vote, comment:, author: user) }
        let(:help_definition_string) { "The weight of the vote (1 for upvote, -1 for downvote)" }

        it_behaves_like "a download your data entity"
      end

      context "when the user has an identity" do
        let!(:identity) { create(:identity, user:) }
        let(:help_definition_string) { "The user that this identity belongs to" }

        it_behaves_like "a download your data entity"
      end
    end
  end
end
