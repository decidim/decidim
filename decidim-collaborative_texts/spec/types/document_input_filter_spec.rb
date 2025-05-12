# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module CollaborativeTexts
    describe DocumentInputFilter, type: :graphql do
      include_context "with a graphql class type"
      let(:type_class) { Decidim::CollaborativeTexts::DocumentsType }

      let(:model) { create(:collaborative_text_component, :published) }
      let!(:models) { create_list(:collaborative_text_document, 3, :published, component: model) }

      context "when filtered by created_at" do
        include_examples "connection has before/since input filter", "collaborativeTexts", "created"
      end

      context "when filtered by updated_at" do
        include_examples "connection has before/since input filter", "collaborativeTexts", "updated"
      end
    end
  end
end
