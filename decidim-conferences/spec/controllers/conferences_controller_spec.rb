# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe ConferencesController do
      routes { Decidim::Conferences::Engine.routes }

      include Decidim::Core::Engine.routes.url_helpers

      let(:organization) { create(:organization) }

      let!(:unpublished_conference) do
        create(
          :conference,
          :unpublished,
          organization:
        )
      end

      let!(:published) do
        create(
          :conference,
          :published,
          organization:
        )
      end

      let!(:promoted) do
        create(
          :conference,
          :published,
          :promoted,
          organization:
        )
      end

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "conferences" do
        it "includes only published, with promoted listed first" do
          expect(controller.helpers.conferences).to contain_exactly(promoted, published)
        end
      end

      describe "promoted_conferences" do
        it "includes only promoted" do
          expect(controller.helpers.promoted_conferences).to contain_exactly(promoted)
        end
      end

      describe "GET show" do
        context "when the conference is unpublished" do
          it "redirects to sign in path" do
            get :show, params: { slug: unpublished_conference.slug, locale: I18n.locale }

            expect(response).to redirect_to(new_user_session_path)
          end

          context "with signed in user" do
            let!(:user) { create(:user, :confirmed, organization:) }

            before do
              sign_in user, scope: :user
            end

            it "redirects to root path" do
              get :show, params: { slug: unpublished_conference.slug, locale: I18n.locale }

              expect(response).to redirect_to(root_path)
            end
          end
        end
      end
    end
  end
end
