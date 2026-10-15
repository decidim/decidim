# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe VersionsController, versioning: true do
      routes { Decidim::Initiatives::Engine.routes }

      let(:resource) { create(:initiative) }

      it_behaves_like "versions controller"

      context "when the initiative is not publicly readable" do
        let(:initiative) { create(:initiative, :created, organization:) }
        let(:organization) { create(:organization) }

        before do
          request.env["decidim.current_organization"] = organization
        end

        it "denies the versions to an anonymous visitor" do
          get :show, params: { initiative_slug: initiative.slug, id: 1, locale: I18n.locale }

          expect(response).not_to have_http_status(:ok)
        end
      end
    end
  end
end
