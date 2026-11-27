# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentActivityCell, type: :cell do
      controller Decidim::LastActivitiesController

      let(:component) { create(:collaborative_text_component) }
      let(:document) { create(:collaborative_text_document, :published, component:) }
      let!(:version) { create(:collaborative_text_version, document:) }
      let(:suggestion) { create(:collaborative_text_suggestion, document_version: version) }
      let!(:comment) { create(:comment, commentable: suggestion) }
      let(:action_log) do
        create(
          :action_log,
          resource: comment,
          organization: comment.organization,
          component: comment.component,
          participatory_space: comment.participatory_space
        )
      end

      it "renders the comment activity card with the document title" do
        html = cell("decidim/comments/comment_activity", action_log).call

        expect(html).to have_css("[data-activity]")
        expect(html).to have_text("New comment:")
        expect(html).to have_text(translated(document.title))
      end
    end
  end
end
