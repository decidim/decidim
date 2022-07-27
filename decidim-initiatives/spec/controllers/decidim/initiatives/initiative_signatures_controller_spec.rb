# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativeSignaturesController, type: :controller do
      routes { Decidim::Initiatives::Engine.routes }

      let(:organization) { create(:organization) }
      let(:initiative_with_user_extra_fields) { create(:initiative, :with_user_extra_fields_collection, organization:) }
      let(:initiative_without_user_extra_fields) { create(:initiative, organization:) }
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
              expect(response).to have_http_status(:unprocessable_entity)
              expect(response.content_type).to eq("text/javascript; charset=utf-8")
            end
          end

          context "and initiative without user extra fields required" do
            it "can vote" do
              expect do
                sign_in initiative_without_user_extra_fields.author, scope: :user
                post :create, params: { initiative_slug: initiative_without_user_extra_fields.slug, format: :js }
              end.to change { InitiativesVote.where(initiative: initiative_without_user_extra_fields).count }.by(1)
            end
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
            end.not_to(change { InitiativesVote.where(initiative:).count })
          end
        end
      end

      context "when GET show first step" do
        let(:initiative) { initiative_with_user_extra_fields }

        context "and Authorized user" do
          it "can get first step" do
            sign_in initiative.author, scope: :user

            get :show, params: { initiative_slug: initiative.slug, id: :fill_personal_data }
            expect(subject.helpers.current_initiative).to eq(initiative)
            expect(subject.helpers.extra_data_legal_information).to eq(initiative.scoped_type.type.extra_fields_legal_information)
          end
        end
      end

      context "when GET initiative_signatures" do
        context "and initiative without user extra fields required" do
          it "action is unavailable" do
            sign_in initiative_without_user_extra_fields.author, scope: :user
            expect { get :show, params: { initiative_slug: initiative_without_user_extra_fields.slug, id: :fill_personal_data } }.to raise_error(Wicked::Wizard::InvalidStepError)
          end
        end
      end
    end
  end
end
