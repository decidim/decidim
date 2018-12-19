# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativeSignaturesController, type: :controller do
      routes { Decidim::Initiatives::Engine.routes }

      let(:organization) { create(:organization) }
      let(:initiative_with_user_extra_fields) { create(:initiative, :with_user_extra_fields_collection, organization: organization) }
      let(:initiative_without_user_extra_fields) { create(:initiative, organization: organization) }
      let(:initiative) { initiative_without_user_extra_fields }

      before do
        request.env["decidim.current_organization"] = organization
      end

      context "when POST create" do
        context "and authorized user" do
          context "and initiative with user extra fields required" do
            it "can't vote" do
              sign_in initiative_with_user_extra_fields.author, scope: :user
              post :create, params: { initiative_slug: initiative_with_user_extra_fields.slug, format: :js }
              parsed_response = JSON.parse(response.body)
              expect(response).to have_http_status(:unprocessable_entity)
              expect(parsed_response.keys).to include("error")
            end
          end

          context "and initiative with user extra fields required" do
            it "can vote" do
              expect do
                sign_in initiative_without_user_extra_fields.author, scope: :user
                post :create, params: { initiative_slug: initiative_without_user_extra_fields.slug, format: :js }
              end.to change { InitiativesVote.where(initiative: initiative_without_user_extra_fields).count }.by(1)
            end
          end
        end

        context "and not authorized user" do
          let(:user) { create(:user, :confirmed, organization: organization) }

          it "can't vote" do
            sign_in user, scope: :user
            post :create, params: { initiative_slug: initiative.slug, format: :js }
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:found)
          end

          it "do not register the vote" do
            expect do
              sign_in user, scope: :user
              post :create, params: { initiative_slug: initiative.slug, format: :js }
            end.not_to(change { InitiativesVote.where(initiative: initiative).count })
          end
        end

        context "and Guest users" do
          it "receives unauthorized response" do
            post :create, params: { initiative_slug: initiative.slug, format: :js }
            expect(response).to have_http_status(:unauthorized)
          end

          it "do not register the vote" do
            expect do
              post :create, params: { initiative_slug: initiative.slug, format: :js }
            end.not_to(change { InitiativesVote.where(initiative: initiative).count })
          end
        end
      end

      context "when GET show first step" do
        context "and Authorized user" do
          it "can get first step" do
            sign_in initiative.author, scope: :user

            get :show, params: { initiative_slug: initiative.slug, id: :fill_personal_data }
            expect(subject.helpers.current_initiative).to eq(initiative)
            expect(subject.helpers.extra_data_legal_information).to eq(initiative.scoped_type.type.extra_fields_legal_information)
          end
        end

        context "and not Authorized user" do
          let(:user) { create(:user, :confirmed, organization: organization) }

          it "can't get first step" do
            sign_in user, scope: :user

            get :show, params: { initiative_slug: initiative.slug, id: :fill_personal_data }
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:found)
          end
        end
      end
    end
  end
end
