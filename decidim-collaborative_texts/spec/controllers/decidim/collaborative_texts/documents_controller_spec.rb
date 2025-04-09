# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe DocumentsController do
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:component) { create(:collaborative_text_component) }
      let(:published_at) { Time.current }
      let!(:published_document) { create(:collaborative_text_document, component:, published_at:) }
      let!(:unpublished_document) { create(:collaborative_text_document, component:) }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      describe "GET #index" do
        it "renders the index template" do
          get :index
          expect(response).to render_template(:index)
          expect(controller.helpers.documents).to include(published_document)
          expect(controller.helpers.documents).not_to include(unpublished_document)
        end
      end

      describe "GET #show" do
        context "when document exists" do
          before { get :show, params: { id: published_document.id } }

          it "document helper returns document" do
            expect(controller.helpers.document).to eq(published_document)
          end
        end

        context "when document does not exist" do
          it "raises an ActiveRecord::RecordNotFound error" do
            expect { get :show, params: { id: "non-existent" } }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
