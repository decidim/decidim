# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/softdeleteable_components_examples"

module Decidim
  module CollaborativeTexts
    module Admin
      describe DocumentsController do
        routes { Decidim::CollaborativeTexts::AdminEngine.routes }

        let(:current_user) { create(:user, :admin, :confirmed, organization:) }
        let(:organization) { create(:organization) }
        let(:participatory_space) { create(:participatory_process, organization:) }
        let!(:component) { create(:collaborative_texts_component, participatory_space:) }
        let!(:collaborative_text_document) { create(:collaborative_text_document, component:) }
        let(:params) { { id: collaborative_text_document.id } }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = component
          sign_in current_user
          allow(controller).to receive(:current_participatory_space).and_return(participatory_space)
          allow(controller).to receive(:current_component).and_return(component)
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
      end
    end
  end
end
