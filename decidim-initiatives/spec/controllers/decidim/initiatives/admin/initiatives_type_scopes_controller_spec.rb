# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe InitiativesTypeScopesController, type: :controller do
        routes { Decidim::Initiatives::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:admin_user) { create(:user, :confirmed, :admin, organization:) }
        let(:user) { create(:user, :confirmed, organization:) }
        let(:initiative_type) do
          create(:initiatives_type, organization:)
        end
        let(:initiative_type_scope) do
          create(:initiatives_type_scope, type: initiative_type)
        end

        let(:valid_attributes) do
          attrs = attributes_for(:initiatives_type_scope, type: initiative_type)
          {
            decidim_scopes_id: attrs[:scope],
            supports_required: attrs[:supports_required]
          }
        end

        let(:invalid_attributes) do
          attrs = attributes_for(:initiatives_type_scope, type: initiative_type)
          {
            decidim_scopes_id: attrs[:scope],
            supports_required: nil
          }
        end

        before do
          request.env["decidim.current_organization"] = organization
        end

        context "when new" do
          context "and admin user" do
            before do
              sign_in admin_user, scope: :user
            end

            it "gets loaded" do
              get :new, params: { initiatives_type_id: initiative_type.id }
              expect(flash[:alert]).to be_nil
              expect(response).to have_http_status(:ok)
            end
          end

          context "and regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              get :new, params: { initiatives_type_id: initiative_type.id }
              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end

        context "when create" do
          context "and admin user" do
            before do
              sign_in admin_user, scope: :user
            end

            it "gets created" do
              expect do
                post :create,
                     params: {
                       initiatives_type_id: initiative_type.id,
                       initiatives_type_scope: valid_attributes
                     }
              end.to change(InitiativesTypeScope, :count).by(1)
            end

            it "fails creation" do
              expect do
                post :create,
                     params: {
                       initiatives_type_id: initiative_type.id,
                       initiatives_type_scope: invalid_attributes
                     }
              end.to change(InitiativesTypeScope, :count).by(0)
            end
          end

          context "and regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              post :create,
                   params: {
                     initiatives_type_id: initiative_type.id,
                     initiatives_type_scope: valid_attributes
                   }
              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end

        context "when edit" do
          context "and admin user" do
            before do
              sign_in admin_user, scope: :user
            end

            it "gets loaded" do
              get :edit,
                  params: {
                    initiatives_type_id: initiative_type.id,
                    id: initiative_type_scope.to_param
                  }
              expect(flash[:alert]).to be_nil
              expect(response).to have_http_status(:ok)
            end
          end

          context "and regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              get :edit,
                  params: {
                    initiatives_type_id: initiative_type.id,
                    id: initiative_type_scope.to_param
                  }
              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end

        context "when update" do
          context "and admin user" do
            before do
              sign_in admin_user, scope: :user
            end

            it "gets updated" do
              patch :update,
                    params: {
                      initiatives_type_id: initiative_type.to_param,
                      id: initiative_type_scope.to_param,
                      initiatives_type_scope: valid_attributes
                    }
              expect(flash[:alert]).to be_nil

              initiative_type_scope.reload
              expect(initiative_type_scope.supports_required).to eq(valid_attributes[:supports_required])
            end

            it "fails update" do
              patch :update,
                    params: {
                      initiatives_type_id: initiative_type.to_param,
                      id: initiative_type_scope.to_param,
                      initiatives_type_scope: invalid_attributes
                    }
              expect(flash[:alert]).not_to be_empty
            end
          end

          context "and regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              patch :update,
                    params: {
                      initiatives_type_id: initiative_type.to_param,
                      id: initiative_type_scope.to_param,
                      initiatives_type_scope: valid_attributes
                    }
              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end

        context "when destroy" do
          context "and admin user" do
            before do
              sign_in admin_user
            end

            it "removes the initiative type if not used" do
              delete :destroy,
                     params: {
                       initiatives_type_id: initiative_type.id,
                       id: initiative_type_scope.to_param
                     }

              scope = InitiativesTypeScope.find_by(id: initiative_type_scope.id)
              expect(scope).to be_nil
            end

            it "fails if the initiative type scope is being used" do
              create(:initiative, organization:, scoped_type: initiative_type_scope)

              expect do
                delete :destroy,
                       params: {
                         initiatives_type_id: initiative_type.id,
                         id: initiative_type_scope.to_param
                       }
              end.to change(InitiativesTypeScope, :count).by(0)
            end
          end

          context "and regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              delete :destroy,
                     params: {
                       initiatives_type_id: initiative_type.id,
                       id: initiative_type_scope.to_param
                     }
              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end
      end
    end
  end
end
