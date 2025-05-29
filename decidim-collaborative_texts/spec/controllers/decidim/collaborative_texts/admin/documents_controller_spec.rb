# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/softdeleteable_components_examples"

module Decidim
  module CollaborativeTexts
    module Admin
      describe DocumentsController do

        let(:current_user) { create(:user, :admin, :confirmed, organization:) }
        let(:organization) { create(:organization) }
        let(:participatory_space) { create(:participatory_process, organization:) }
        let!(:component) { create(:collaborative_text_component, participatory_space:) }
        let!(:collaborative_text_document) { create(:collaborative_text_document, component:, document_versions:) }
        let(:document_versions) { [build(:collaborative_text_version)] }
        let(:params) do
          {
            title: title,
            body: body
          }
        end
        let(:title) { "A nice test document" }
        let(:body) { "This is a test document." }
        let(:documents_path) { Decidim::EngineRouter.admin_proxy(component).documents_path }

        before do
          allow(controller).to receive(:documents_path).and_return(documents_path)
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = component
          request.env["decidim.current_participatory_space"] = participatory_space
          allow(controller).to receive(:current_participatory_space).and_return(participatory_space)
          allow(controller).to receive(:current_component).and_return(component)
        end

        describe "GET #index" do
          it "renders the index template" do
            get :index
            expect(response).to have_http_status(:redirect)
            expect(response).not_to render_template(:index)
          end
        end

        context "when user is signed in" do
          before do
            sign_in current_user
          end

          it_behaves_like "a soft-deletable resource",
                          resource_name: :collaborative_text_document,
                          resource_path: :documents_path,
                          trash_path: :manage_trash_documents_path

          describe "GET #index" do
            it "renders the index template" do
              get :index
              expect(response).to have_http_status(:ok)
              expect(response).to render_template(:index)
            end
          end

          describe "GET #new" do
            it "renders the new template" do
              get :new
              expect(response).to have_http_status(:ok)
              expect(response).to render_template(:new)
            end
          end

          describe "POST #create" do
            it "creates a new document and redirects to index" do
              expect do
                post :create, params: params
              end.to change(Document, :count).by(1)
              expect(response).to redirect_to(documents_path)
              expect(flash[:notice]).to eq("Document successfully created.")
            end

            context "with invalid params" do
              let(:title) { "" }

              it "does not create a document" do
                expect do
                  post :create, params: params
                end.not_to change(Document, :count)
                expect(response).to render_template(:new)
                expect(flash.now[:alert]).to eq("There was a problem creating the document.")
              end
            end
          end

          describe "GET #edit" do
            it "renders the edit template" do
              get :edit, params: { id: collaborative_text_document.id }
              expect(response).to have_http_status(:ok)
              expect(response).to render_template(:edit)
            end
          end

          describe "PATCH #update" do
            it "updates the document and redirects to index" do
              patch :update, params: { id: collaborative_text_document.id, title: "Updated Title", body: body }
              expect(response).to redirect_to(documents_path)
            end
          end

          describe "GET #edit_settings" do
            it "renders the edit settings template" do
              get :edit_settings, params: { id: collaborative_text_document.id }
              expect(response).to have_http_status(:ok)
              expect(response).to render_template(:edit_settings)
            end
          end

          describe "PATCH #update_settings" do
            it "updates the document settings and redirects to index" do
              patch :update_settings, params: { id: collaborative_text_document.id, announcement: { en: "Updated announcement" } }
              expect(response).to redirect_to(documents_path)
            end

            context "with invalid params" do
              let(:title) { "" }

              it "does not update the document settings" do
                patch :update_settings, params: { id: collaborative_text_document.id, title: "", body: body }
                expect(response).to render_template(:edit_settings)
                expect(flash.now[:alert]).to eq("There was a problem updating the document.")
              end
            end
          end

          describe "GET #publish" do
            it "publishes the document and redirects to index" do
              get :publish, params: { id: collaborative_text_document.id }
              expect(response).to redirect_to(documents_path)
              expect(flash[:notice]).to eq("Document successfully published.")
            end
          end

          describe "GET #unpublish" do
            let!(:collaborative_text_document) { create(:collaborative_text_document, :published, component:, document_versions:) }

            it "unpublishes the document and redirects to index" do
              get :unpublish, params: { id: collaborative_text_document.id }
              expect(response).to redirect_to(documents_path)
              expect(flash[:notice]).to eq("Document successfully unpublished.")
            end
          end
        end
      end
    end
  end
end
