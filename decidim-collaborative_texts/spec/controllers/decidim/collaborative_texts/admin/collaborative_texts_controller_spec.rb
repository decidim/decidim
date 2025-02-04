# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    module Admin
      describe CollaborativeTextsController do
        routes { Decidim::CollaborativeTexts::AdminEngine.routes }

        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:organization) { create(:organization) }
        let(:participatory_space) { create(:participatory_process, organization:) }
        let!(:component) { create(:collaborative_texts_component, participatory_space:) }

        before do
          request.env["decidim.current_organization"] = user.organization
          sign_in user, scope: :user
          allow(controller).to receive(:current_participatory_space).and_return(participatory_space)
          allow(controller).to receive(:current_component).and_return(component)
        end

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
