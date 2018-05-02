# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe InitiativesTypesController, type: :controller do
        routes { Decidim::Initiatives::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:admin_user) { create(:user, :confirmed, :admin, organization: organization) }
        let(:user) { create(:user, :confirmed, organization: organization) }
        let(:initiative_type) do
          create(:initiatives_type, organization: organization)
        end

        let(:valid_attributes) do
          attributes_for(:initiatives_type, organization: organization)
        end

        let(:invalid_attributes) do
          attributes_for(:initiatives_type, organization: organization, title: { "en" => "" })
        end

        before do
          request.env["decidim.current_organization"] = organization
        end

        context "when index" do
          context "and admin user" do
            before do
              sign_in admin_user, scope: :user
            end

            it "gets loaded" do
              get :index
              expect(flash[:alert]).to be_nil
              expect(response).to have_http_status(:ok)
            end
          end

          context "and regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              get :index
              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end

        context "when new" do
          context "and admin user" do
            before do
              sign_in admin_user, scope: :user
            end

            it "gets loaded" do
              get :new
              expect(flash[:alert]).to be_nil
              expect(response).to have_http_status(:ok)
            end
          end

          context "and regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              get :new
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
                post :create, params: { initiatives_type: valid_attributes }
              end.to change(InitiativesType, :count).by(1)
            end

            it "fails creation" do
              expect do
                post :create, params: { initiatives_type: invalid_attributes }
              end.to change(InitiativesType, :count).by(0)
            end
          end

          context "and regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              post :create,
                   params: { initiatives_type: valid_attributes }
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
              get :edit, params: { id: initiative_type.to_param }
              expect(flash[:alert]).to be_nil
              expect(response).to have_http_status(:ok)
            end
          end

          context "and regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              get :edit, params: { id: initiative_type.to_param }
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
                      id: initiative_type.id,
                      initiatives_type: valid_attributes
                    }
              expect(flash[:alert]).to be_nil

              initiative_type.reload
              expect(initiative_type.title).to eq(valid_attributes[:title])
              expect(initiative_type.description).to eq(valid_attributes[:description])
            end

            it "fails update" do
              patch :update,
                    params: {
                      id: initiative_type.id,
                      initiatives_type: invalid_attributes
                    }
              expect(flash[:alert]).not_to be_empty
            end
          end

          context "when regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              patch :update,
                    params: {
                      id: initiative_type.id,
                      initiatives_type: valid_attributes
                    }
              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end

        context "when destroy" do
          context "and admin user" do
            before do
              sign_in admin_user, scope: :user
            end

            it "removes the initiative type if not used" do
              delete :destroy, params: { id: initiative_type.id }
              expect(InitiativesType.find_by(id: initiative_type.id)).to be_nil
            end

            it "fails if the initiative type is being used" do
              scoped_type = create(:initiatives_type_scope, type: initiative_type)
              create(:initiative, organization: organization, scoped_type: scoped_type)

              expect do
                delete :destroy, params: { id: initiative_type.id }
              end.to change(InitiativesType, :count).by(0)
            end
          end

          context "and regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              delete :destroy, params: { id: initiative_type.id }
              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end
      end
    end
  end
end
