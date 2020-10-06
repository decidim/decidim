# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativesController, type: :controller do
      routes { Decidim::Initiatives::Engine.routes }

      let(:organization) { create(:organization) }
      let!(:initiative) { create(:initiative, organization: organization) }
      let!(:created_initiative) { create(:initiative, :created, organization: organization) }

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "GET index" do
        it "Only returns published initiatives" do
          get :index
          expect(subject.helpers.initiatives).to include(initiative)
          expect(subject.helpers.initiatives).not_to include(created_initiative)
        end

        context "when order by most_voted" do
          let(:voted_initiative) { create(:initiative, organization: organization) }
          let!(:vote) { create(:initiative_user_vote, initiative: voted_initiative) }

          it "most voted appears first" do
            get :index, params: { order: "most_voted" }

            expect(subject.helpers.initiatives.first).to eq(voted_initiative)
          end
        end

        context "when order by most recent" do
          let!(:old_initiative) { create(:initiative, organization: organization, created_at: initiative.created_at - 12.months) }

          it "most recent appears first" do
            get :index, params: { order: "recent" }
            expect(subject.helpers.initiatives.first).to eq(initiative)
          end
        end

        context "when order by most recently published" do
          let!(:old_initiative) { create(:initiative, organization: organization, published_at: initiative.published_at - 12.months) }

          it "most recent appears first" do
            get :index, params: { order: "recently_published" }
            expect(subject.helpers.initiatives.first).to eq(initiative)
          end
        end

        context "when order by most commented" do
          let(:commented_initiative) { create(:initiative, organization: organization) }
          let!(:comment) { create(:comment, commentable: commented_initiative) }

          it "most commented appears fisrt" do
            get :index, params: { order: "most_commented" }
            expect(subject.helpers.initiatives.first).to eq(commented_initiative)
          end
        end
      end

      describe "GET show" do
        context "and any user" do
          it "Shows published initiatives" do
            get :show, params: { slug: initiative.slug }
            expect(subject.helpers.current_initiative).to eq(initiative)
          end

          it "Throws exception on non published initiatives" do
            get :show, params: { slug: created_initiative.slug }
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:found)
          end
        end

        context "and initiative Owner" do
          before do
            sign_in created_initiative.author, scope: :user
          end

          it "Unpublished initiatives are shown too" do
            get :show, params: { slug: created_initiative.slug }
            expect(subject.helpers.current_initiative).to eq(created_initiative)
          end
        end
      end

      describe "Edit initiative as promoter" do
        before do
          sign_in created_initiative.author, scope: :user
        end

        it "Unpublished initiatives are shown too" do
          get :edit, params: { slug: created_initiative.slug }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
