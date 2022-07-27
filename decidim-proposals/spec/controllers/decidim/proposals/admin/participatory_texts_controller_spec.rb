# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ParticipatoryTextsController, type: :controller do
        routes { Decidim::Proposals::AdminEngine.routes }

        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }
        let(:component) { create :proposal_component, :with_participatory_texts_enabled }
        let(:document_file) { upload_test_file(Decidim::Dev.asset("participatory_text.md"), content_type: "text/markdown") }
        let(:title) { { en: ::Faker::Book.title } }
        let(:params) do
          {
            component_id: component.id,
            participatory_process_slug: component.participatory_space.slug,
            title:,
            description: {},
            document: document_file
          }
        end

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "POST import" do
          context "when the command fails" do
            let(:title) { {} }

            it "renders new_import template" do
              post :import, params: params
              expect(response).to render_template(:new_import)
              expect(flash[:alert]).to eq("The form is invalid!")
            end
          end

          context "when the command succeeds" do
            it "parses the document" do
              post :import, params: params
              expect(response).to redirect_to EngineRouter.admin_proxy(component).participatory_texts_path
              expect(flash[:notice].starts_with?("Congratulations")).to be true
            end
          end
        end
      end
    end
  end
end
