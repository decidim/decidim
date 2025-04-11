# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module CollaborativeTexts
    describe DocumentInputSort, type: :graphql do
      include_context "with a graphql class type"

      let(:type_class) { Decidim::CollaborativeTexts::DocumentsType }

      let(:model) { create(:collaborative_text_component) }
      let!(:models) { create_list(:collaborative_text_document, 3, :published, component: model) }

      context "when sorting by documents id" do
        include_examples "connection has input sort", "collaborativeTexts", "id"
      end

      context "when sorting by created_at" do
        include_examples "connection has input sort", "collaborativeTexts", "createdAt"
      end

      context "when sorting by updated_at" do
        include_examples "connection has input sort", "collaborativeTexts", "updatedAt"
      end
    end
  end
end
