# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Meetings
    describe CreateMeetingType do
      include_context "with a graphql class mutation"

      let(:type_class) { Decidim::Meetings::CreateMeetingType }
      let(:root_klass) { Decidim::Meetings::MeetingsMutationType }

      let(:current_organization) { create(:organization, available_locales: [:en]) }
      let(:organization) { current_organization }
      let(:participatory_process) { create(:participatory_process, :published, :with_steps, organization:) }

      let(:locale) { "en" }
      let(:translation_locale) { "en" }

      let!(:current_component) do
        create(:meeting_component, :published, participatory_space: participatory_process, settings: {
                 creation_enabled_for_participants: true,
                 taxonomy_filters: [taxonomy_filter.id]
               })
      end
      let(:root_taxonomy) { create(:taxonomy, organization:) }
      let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
      let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
      let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
      let!(:user) { create(:user, :confirmed, organization:) }

      let(:title) { "More sidewalks and less roads" }
      let(:description) { "Cities need more people, not more cars" }
      let(:address) { "Carrer de la Pau, 1, Barcelona" }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }
      let(:start_time) { 1.day.from_now }
      let(:end_time) { start_time + 2.hours }
      let(:iframe_embed_type) { "NONE" }
      let(:iframe_access_level) { "ALL" }
      let(:location) { "Somewhere" }
      let(:location_hints) { "Near the main square" }
      let(:online_meeting_url) { "https://meets.example.org/abc-def" }
      let(:registration_terms) { "By registering you agree to the terms and conditions" }
      let(:registration_type) { "ON_THIS_PLATFORM" }
      let(:registration_url) { "https://example.org/register" }
      let(:registrations_enabled) { true }
      let(:type_of_meeting) { "ONLINE" }

      let(:root_value) { current_component }
      let(:query) do
        <<~GRAPHQL
          mutation createMeetings($input: CreateMeetingInput!){
            createMeeting(input: $input) {
              id
              title { translation(locale: "#{translation_locale}") }
              description { translation(locale: "#{translation_locale}") }
              address
              coordinates { latitude longitude }
              publishedAt
              author { name }
              taxonomies { id }
              remainingSlots
              location  { translation(locale: "#{translation_locale}") }
              locationHints { translation(locale: "#{translation_locale}") }
              onlineMeetingUrl
              registrationTerms { translation(locale: "#{translation_locale}") }
              registrationType
              registrationUrl
              endTime
              startTime
              typeOfMeeting
              registrationsEnabled
            }
          }
        GRAPHQL
      end

      let(:attributes) do
        {
          address:,
          availableSlots: 10,
          description:,
          endTime: end_time.iso8601,
          iframeAccessLevel: iframe_access_level,
          iframeEmbedType: iframe_embed_type,
          latitude:,
          location:,
          locationHints: location_hints,
          longitude:,
          onlineMeetingUrl: online_meeting_url,
          registrationTerms: registration_terms,
          registrationType: registration_type,
          registrationUrl: registration_url,
          registrationsEnabled: registrations_enabled,
          startTime: start_time.iso8601,
          taxonomies: [taxonomy.id],
          title:,
          typeOfMeeting: type_of_meeting
        }
      end

      let(:variables) do
        {
          component_id: current_component.id,
          input: {
            locale:,
            attributes:
          }
        }
      end

      before do
        stub_geocoding(address, [latitude, longitude])
      end

      context "when validating" do
        context "with having invalid locale" do
          let(:locale) { "tlh" }

          it "raises an error" do
            expect { response }.to raise_error(Api::Errors::InvalidLocaleError, /Invalid locale provided/)
          end
        end

        context "with having invalid title" do
          context "when is missing" do
            let(:title) { "" }

            it "raises an error" do
              expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
            end
          end
        end

        context "with having invalid registration type" do
          let(:registration_type) { "INVALID_TYPE" }

          it "raises an error" do
            expect { response }.to raise_error(GraphQL::ExecutionError, /to be one of: REGISTRATION_DISABLED, ON_THIS_PLATFORM, ON_DIFFERENT_PLATFORM/)
          end
        end

        context "with having invalid meeting type" do
          let(:type_of_meeting) { "INVALID_TYPE" }

          it "raises an error" do
            expect { response }.to raise_error(GraphQL::ExecutionError, /to be one of: HYBRID, IN_PERSON, ONLINE/)
          end
        end
      end

      shared_examples "create meeting mutation examples" do
        context "when creation is disabled" do
          let!(:current_component) { create(:meeting_component, :published, participatory_space: participatory_process) }

          it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
          end
        end

        context "when user is logged in" do
          it "creates a new meeting" do
            meeting_response = response["createMeeting"]

            expect(meeting_response).to be_present
            expect(meeting_response["title"]["translation"]).to eq(title)
            expect(meeting_response["description"]["translation"]).to include(description)
            expect(meeting_response["publishedAt"]).to be_present
            expect(meeting_response["taxonomies"]).to include({ "id" => taxonomy.id.to_s })
            expect(meeting_response["author"]["name"]).to eq(current_user.name)
            expect(meeting_response["remainingSlots"]).to eq(10)
            expect(meeting_response["location"]).to include({ "translation" => location })
            expect(meeting_response["locationHints"]).to include({ "translation" => location_hints })
            expect(meeting_response["registrationTerms"]).to include({ "translation" => registration_terms })

            expect(meeting_response["onlineMeetingUrl"]).to eq(online_meeting_url)
            expect(meeting_response["registrationType"]).to eq(registration_type)
            expect(meeting_response["registrationUrl"]).to eq(registration_url)
            expect(meeting_response["endTime"]).to eq(end_time.to_time.iso8601)
            expect(meeting_response["startTime"]).to eq(start_time.to_time.iso8601)
            expect(meeting_response["typeOfMeeting"]).to eq(type_of_meeting)
            expect(meeting_response["registrationsEnabled"]).to eq(registrations_enabled)

            expect(meeting_response["address"]).to eq(address)
            expect(meeting_response["coordinates"]).to include(
              "latitude" => latitude,
              "longitude" => longitude
            )
          end

          context "when submitting in one language and requesting in another" do
            let(:locale) { "en" }
            let(:translation_locale) { "es" }

            it "creates a new meeting" do
              meeting_response = response["createMeeting"]

              expect(meeting_response).to be_present
              expect(meeting_response["title"]["translation"]).to be_nil
            end
          end
        end
      end

      context "with admin user" do
        it_behaves_like "create meeting mutation examples" do
          let!(:user_type) { :admin }
        end
      end

      context "with normal user" do
        it_behaves_like "create meeting mutation examples" do
          let!(:user_type) { :user }
        end
      end

      context "with api_user" do
        it_behaves_like "create meeting mutation examples" do
          let!(:user_type) { :api_user }
        end
      end

      context "when the user is not logged in" do
        let(:current_user) { nil }

        it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
        end
      end
    end
  end
end
