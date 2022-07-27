# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    module Admin
      describe SortitionsController, type: :controller do
        routes { Decidim::Sortitions::AdminEngine.routes }

        let(:component) { sortition.component }
        let(:sortition) { create(:sortition) }
        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user, scope: :user
        end

        describe "show" do
          let(:sortition) { create(:sortition) }
          let(:params) do
            {
              component_id: sortition.component.id,
              participatory_process_slug: sortition.component.participatory_space.slug,
              id: sortition.id
            }
          end

          it "renders the show template" do
            get :show, params: params
            expect(response).to render_template(:show)
          end
        end

        describe "new" do
          let(:params) do
            { participatory_process_slug: component.participatory_space.slug }
          end

          it "renders the new template" do
            get :new, params: params
            expect(response).to render_template(:new)
          end
        end

        describe "create" do
          let(:decidim_category_id) { nil }
          let(:dice) { ::Faker::Number.between(from: 1, to: 6) }
          let(:target_items) { ::Faker::Number.between(from: 1, to: 10) }
          let(:params) do
            {
              participatory_process_slug: sortition.component.participatory_space.slug,
              sortition: {
                decidim_proposals_component_id:,
                decidim_category_id:,
                dice:,
                target_items:,
                title: {
                  en: "Title",
                  es: "Título",
                  ca: "Títol"
                },
                witnesses: {
                  en: "Witnesses",
                  es: "Testigos",
                  ca: "Testimonis"
                },
                additional_info: {
                  en: "Additional information",
                  es: "Información adicional",
                  ca: "Informació adicional"
                }
              }
            }
          end

          context "with invalid params" do
            let(:decidim_proposals_component_id) { nil }

            it "renders the new template" do
              post :create, params: params
              expect(response).to render_template(:new)
            end
          end

          context "with valid params" do
            let(:proposal_component) { create(:proposal_component, participatory_space: component.participatory_space) }
            let(:decidim_proposals_component_id) { proposal_component.id }

            it "redirects to show newly created sortition" do
              expect(controller).to receive(:redirect_to) do |params|
                expect(params).to eq(action: :show, id: Sortition.last.id)
              end

              post :create, params:
            end

            it "Sortition author is the current user" do
              expect(controller).to receive(:redirect_to) do |params|
                expect(params).to eq(action: :show, id: Sortition.last.id)
              end

              post :create, params: params
              expect(Sortition.last.author).to eq(user)
            end
          end
        end

        describe "confirm_destroy" do
          let(:sortition) { create(:sortition) }
          let(:params) do
            {
              component_id: sortition.component.id,
              participatory_process_slug: sortition.component.participatory_space.slug,
              id: sortition.id
            }
          end

          it "renders the confirm_destroy template" do
            get :confirm_destroy, params: params
            expect(response).to render_template(:confirm_destroy)
          end
        end

        describe "destroy" do
          let(:cancel_reason) do
            {
              en: "Cancel reason",
              es: "Motivo de la cancelación",
              ca: "Motiu de la cancelació"
            }
          end
          let(:params) do
            {
              participatory_process_slug: component.participatory_space.slug,
              id: sortition.id,
              sortition: {
                cancel_reason:
              }
            }
          end

          context "with invalid params" do
            let(:cancel_reason) do
              {
                en: "",
                es: "",
                ca: ""
              }
            end

            it "renders the confirm_destroy template" do
              delete :destroy, params: params
              expect(response).to render_template(:confirm_destroy)
            end
          end

          context "with valid params" do
            it "redirects to sortitions list newly created sortition" do
              expect(controller).to receive(:redirect_to).with(action: :index)

              delete :destroy, params:
            end
          end
        end

        describe "edit" do
          let(:sortition) { create(:sortition) }
          let(:params) do
            {
              participatory_process_slug: component.participatory_space.slug,
              component_id: sortition.component.id,
              id: sortition.id
            }
          end

          it "renders the edit template" do
            get :edit, params: params
            expect(response).to render_template(:edit)
          end
        end

        describe "update" do
          let(:title) do
            {
              en: "Title",
              es: "Título",
              ca: "Títol"
            }
          end
          let(:additional_info) do
            {
              en: "Additional info",
              es: "Información adicional",
              ca: "Informació adicional"
            }
          end
          let(:params) do
            {
              participatory_process_slug: component.participatory_space.slug,
              id: sortition.id,
              sortition: {
                title:,
                additional_info:
              }
            }
          end

          context "with invalid params" do
            let(:title) do
              {
                en: "",
                es: "",
                ca: ""
              }
            end

            it "renders the edit template" do
              patch :update, params: params
              expect(response).to render_template(:edit)
            end
          end

          context "with valid params" do
            it "redirects to sortitions list newly created sortition" do
              expect(controller).to receive(:redirect_to).with(action: :index)

              patch :update, params:
            end
          end
        end
      end
    end
  end
end
