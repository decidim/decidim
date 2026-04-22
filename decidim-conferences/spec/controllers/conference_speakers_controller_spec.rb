# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe ConferenceSpeakersController do
      routes { Decidim::Conferences::Engine.routes }

      let(:organization) { create(:organization) }

      let(:conference) do
        create(
          :conference,
          :published,
          organization:
        )
      end

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "GET index" do
        context "when conference has no speakers" do
          it "redirects to 404" do
            expect { get :index, params: { conference_slug: conference.slug, locale: I18n.locale } }
              .to raise_error(ActionController::RoutingError)
          end
        end

        context "when conference has speakers" do
          let!(:speaker1) { create(:conference_speaker, :published, conference:) }
          let!(:speaker2) { create(:conference_speaker, :published, conference:) }
          let!(:non_speaker) { create(:conference_speaker) }

          context "when user has permissions" do
            it "displays list of speakers" do
              get :index, params: { conference_slug: conference.slug, locale: I18n.locale }

              expect(controller.helpers.collection).to contain_exactly(speaker1, speaker2)
            end
          end
        end
      end
    end
  end
end
