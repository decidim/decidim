# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Devise
    describe PagesController, type: :controller do
      routes { Decidim::Core::Engine.routes }

      let(:organization) { create :organization }

      before do
        request.env["decidim.current_organization"] = organization
      end

      shared_examples "accessible static page" do
        render_views

        it "renders the page contents" do
          get :show, params: { id: page.slug }

          expect(response).to render_template(:show)

          expect(response.body).to include(page.title[I18n.locale.to_s])
          expect(response.body).to include(page.content[I18n.locale.to_s])
        end
      end

      context "when a page exists" do
        let(:page) { create(:static_page, organization:) }

        it_behaves_like "accessible static page"

        context "when asking the page in other formats" do
          it "ignores them" do
            get :show, params: { id: page.slug }, format: :text

            expect(response).to render_template(:show)
          end
        end
      end

      context "when a page doesn't exist" do
        it "redirects to the 404" do
          expect { get :show, params: { id: "some-page" } }
            .to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when organization forces users to authenticate before access" do
        before do
          organization.force_users_to_authenticate_before_access_organization = true
          organization.save
        end

        context "with a publicly accessible page" do
          let(:page) { create(:static_page, organization:, allow_public_access: true) }

          it_behaves_like "accessible static page"
        end

        context "with a publicly hidden page" do
          let(:page) { create(:static_page, organization:, allow_public_access: false) }

          it "redirects to sign in path" do
            get :show, params: { id: page.slug }

            expect(response).to redirect_to("/users/sign_in")
            expect(flash[:warning]).to include("Please, login with your account before access")
          end
        end

        context "when authenticated" do
          let!(:user) { create :user, :confirmed, organization: }

          before do
            sign_in user
          end

          context "with a publicly accessible page" do
            let(:page) { create(:static_page, organization:, allow_public_access: true) }

            it_behaves_like "accessible static page"
          end

          context "with a publicly hidden page" do
            let(:page) { create(:static_page, organization:, allow_public_access: false) }

            it_behaves_like "accessible static page"
          end
        end
      end
    end
  end
end
