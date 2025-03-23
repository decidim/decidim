# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe RegistrationTypesController do
      routes { Decidim::Conferences::Engine.routes }

      let(:organization) { create(:organization) }
      let!(:conference) do
        create(
          :conference,
          :published,
          registrations_enabled:,
          organization:
        )
      end
      let(:registrations_enabled) { true }
      let(:registration_types_count) { 5 }
      let!(:registration_types) do
        create_list(:registration_type, registration_types_count, conference:)
      end

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "index" do
        context "when registration_types is present" do
          it "does not raise an error" do
            get :index, params: { conference_slug: conference.slug, locale: I18n.locale }
            assert_response :success
          end
        end

        context "when registration_types is empty" do
          let(:registration_types) { [] }

          context "and current_participatory_space registrations is enabled" do
            it "does raise an error" do
              expect { get :index, params: { conference_slug: conference.slug, locale: I18n.locale } }
                .to raise_error(ActionController::RoutingError)
            end
          end

          context "and current_participatory_space registrations is disabled" do
            let(:registrations_enabled) { false }

            it "does not raise an error" do
              get :index, params: { conference_slug: conference.slug, locale: I18n.locale }
              assert_response :success
            end
          end
        end
      end
    end
  end
end
