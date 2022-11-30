# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe ConferenceProgramController, type: :controller do
      routes { Decidim::Conferences::Engine.routes }

      let(:organization) { create(:organization) }

      let(:conference) do
        create(
          :conference,
          :published,
          organization: organization
        )
      end

      let!(:component) do
        create(:component, manifest_name: :meetings, participatory_space: conference)
      end

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "GET show" do
        context "when conference has no meetings" do
          it "returns 404" do
            expect { get :show, params: { conference_slug: conference.slug, id: component.id } }
              .to raise_error(ActionController::RoutingError)
          end
        end

        context "when conference has an invalid component id" do
          it "returns 404" do
            expect { get :show, params: { conference_slug: conference.slug, id: 999 } }
              .to raise_error(ActionController::RoutingError)
          end
        end

        context "when conference has meetings" do
          let!(:meetings) do
            create_list(
              :meeting,
              3,
              :published,
              component: component
            )
          end

          context "when user has permissions" do
            it "displays list of program" do
              get :show, params: { conference_slug: conference.slug, id: component.id }

              expect(controller.helpers.collection).to match_array(meetings)
            end
          end

          context "when user does not have permissions" do
            before do
              allow(controller).to receive(:current_user_can_visit_space?).and_return(false)
            end

            it "redirects to conference path" do
              get :show, params: { conference_slug: conference.slug, id: component.id }

              expect(response).to redirect_to(conference_path(conference.slug))
            end
          end
        end
      end
    end
  end
end
