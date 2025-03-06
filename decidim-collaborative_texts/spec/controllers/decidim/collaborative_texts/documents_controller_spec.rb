# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe DocumentsController do
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:component) { create(:collaborative_texts_component) }
      let(:published_at) { Time.current }
      let!(:published_document) { create(:collaborative_text_document, component:, published_at:) }
      let!(:unpublished_document) { create(:collaborative_text_document, component:) }

      let(:document_params) do
        {
          component_id: component.id
        }
      end
      let(:params) { { document: document_params } }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        stub_const("Decidim::Paginable::OPTIONS", [100])
      end

      describe "GET #index" do
        context "when user is an admin" do
          before do
            sign_in user, scope: :user
            allow(user).to receive(:admin?).and_return(true)
            get :index
          end

          it "renders the index template" do
            get :index
            expect(response).to render_template(:index)
          end
        end
      end

      describe "GET #show" do
        context "when document exists" do
          before { get :show, params: { id: published_document.id } }

          it "assigns the requested document to @document" do
            expect(assigns(:document)).to eq(published_document)
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
