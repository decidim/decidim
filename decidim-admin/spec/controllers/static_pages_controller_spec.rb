# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe StaticPagesController, type: :controller do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create :organization }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
      end

      context "when creating a page" do
        it "injects the organization to the form" do
          post :create, params: {}

          expect(assigns(:form).organization).to eq(organization)
        end
      end

      context "when updating a page" do
        let!(:page) { create(:static_page, organization: organization) }

        it "injects the organization to the form" do
          put :update, params: { id: page.id }.with_indifferent_access

          expect(assigns(:form).organization).to eq(organization)
        end

        context "when no slug is given" do
          it "injects it to the form" do
            put :update, params: { id: page.id }.with_indifferent_access

            expect(assigns(:form).slug).to eq(page.slug)
          end
        end

        context "when a slug is given" do
          it "does not overwrite it" do
            put :update, params: { id: page.id, static_page: { slug: "new-slug" } }.with_indifferent_access

            expect(assigns(:form).slug).to eq("new-slug")
          end
        end
      end
    end
  end
end
