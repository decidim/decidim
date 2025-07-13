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
        decidim-comments-comments-
        decidim-comments-commentvotes-
      )
    end

    describe "#data_and_attachments_for_user" do
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
    end
  end
end
