# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe ConferencesController, type: :controller do
      routes { Decidim::Conferences::Engine.routes }

      let(:organization) { create(:organization) }

      let!(:unpublished_conference) do
        create(
          :conference,
          :unpublished,
          organization: organization
        )
      end

      let!(:published) do
        create(
          :conference,
          :published,
          organization: organization
        )
      end

      let!(:promoted) do
        create(
          :conference,
          :published,
          :promoted,
          organization: organization
        )
      end

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "conferences" do
        it "includes only published, with promoted listed first" do
          expect(controller.helpers.conferences).to match_array([promoted, published])
        end
      end

      describe "promoted_conferences" do
        it "includes only promoted" do
          expect(controller.helpers.promoted_conferences).to contain_exactly(promoted)
        end
      end

      describe "GET show" do
        context "when the conference is unpublished" do
          it "redirects to root path" do
            get :show, params: { slug: unpublished_conference.slug }

            expect(response).to redirect_to("/")
          end
        end
      end
    end
  end
end
