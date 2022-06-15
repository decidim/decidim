# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe ConferenceSpeakersController, type: :controller do
      routes { Decidim::Conferences::Engine.routes }

      let(:organization) { create(:organization) }

      let(:conference) do
        create(
          :conference,
          :published,
          organization: organization
        )
      end

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "GET index" do
        context "when conference has no speakers" do
          it "redirects to 404" do
            expect { get :index, params: { conference_slug: conference.slug } }
              .to raise_error(ActionController::RoutingError)
          end
        end

        context "when conference has speakers" do
          let!(:speaker1) { create(:conference_speaker, conference: conference) }
          let!(:speaker2) { create(:conference_speaker, conference: conference) }
          let!(:non_speaker) { create(:conference_speaker) }

          context "when user has permissions" do
            it "displays list of speakers" do
              get :index, params: { conference_slug: conference.slug }

              expect(controller.helpers.collection).to match_array([speaker1, speaker2])
            end
          end

          context "when user does not have permissions" do
            before do
              allow(controller).to receive(:current_user_can_visit_space?).and_return(false)
            end

            it "redirects to conference path" do
              get :index, params: { conference_slug: conference.slug }

              expect(response).to redirect_to(conference_path(conference.slug))
            end
          end
        end
      end
    end
  end
end
