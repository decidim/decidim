# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Meetings
    describe UpdateMeetingType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { MeetingMutationType }
      let(:current_organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization: current_organization) }
      let(:meeting_component) do
        create(:meeting_component, :published, participatory_space: participatory_process, settings: {
                 creation_enabled_for_participants: true,
                 taxonomy_filters: [taxonomy_filter.id]
               })
      end
      let!(:model) { create(:meeting, :published, component: meeting_component, author: current_user) }
      let(:title) { "Updated Meeting Title" }
      let(:description) { "Updated meeting description" }
      let(:location) { "Updated location" }
      let(:start_time) { (2.days.from_now).to_time.iso8601 }
      let(:end_time) { (2.days.from_now + 2.hours).to_time.iso8601 }
      let(:address) { "Updated address, 123" }
      let(:latitude) { 41.1234 }
      let(:longitude) { 2.5678 }
      let(:registration_type) { "ON_THIS_PLATFORM" }
      let(:available_slots) { 50 }
      let(:type_of_meeting) { "ONLINE" }
      let(:online_meeting_url) { "https://meet.example.org/updated-meeting" }
      let(:registration_terms) { "Updated registration terms" }
      let(:root_taxonomy) { create(:taxonomy, organization: current_organization) }
      let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization: current_organization) }
      let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
      let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
      let(:locale) { "en" }

      let(:variables) do
        {
          input: {
            locale:,
            attributes: {
              address:,
              availableSlots: available_slots,
              description:,
              endTime: end_time,
              latitude:,
              location:,
              longitude:,
              onlineMeetingUrl: online_meeting_url,
              registrationTerms: registration_terms,
              registrationType: registration_type,
              startTime: start_time,
              taxonomies: [taxonomy.id],
              title:,
              typeOfMeeting: type_of_meeting
            }
          }
        }
      end

      let(:query) do
        <<~GRAPHQL
          mutation($input: UpdateMeetingInput!) {
            update(input: $input) {
              address
              description { translation(locale: "en") }
              endTime
              id
              location { translation(locale: "en") }
              registrationType
              startTime
              taxonomies { id }
              title { translation(locale: "en") }
            }
          }
        GRAPHQL
      end

      shared_examples "update meeting mutation examples" do
        context "when user has permission to update" do
          it "the meeting" do
            meeting_response = response["update"]
            expect(meeting_response).to be_present
            expect(meeting_response).to include(
              {
                "id" => model.id.to_s,
                "title" => {
                  "translation" => title
                },
                "description" => {
                  "translation" => description
                },
                "location" => {
                  "translation" => location
                },
                "address" => address,
                "registrationType" => registration_type
              }
            )

            expect(meeting_response["taxonomies"]).to include({ "id" => taxonomy.id.to_s })

            # Verify the meeting was actually updated in the database
            model.reload
            expect(model.title["en"]).to eq(title)
            expect(model.description["en"]).to eq(description)
            expect(model.address).to eq(address)
          end

          context "when validating" do
            context "with having invalid locale" do
              let(:locale) { "tlh" }

              it "raises an error" do
                expect { response }.to raise_error(Api::Errors::InvalidLocaleError, /Invalid locale provided/)
              end
            end

            context "with invalid title" do
              let(:title) { "" }

              it "raises an error" do
                expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
              end
            end

            context "with invalid description" do
              let(:description) { "" }

              it "raises an error" do
                expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
              end
            end

            context "with invalid start_time" do
              context "and is empty" do
                let(:start_time) { "" }

                it "raises an error" do
                  expect { response }.to raise_error(ArgumentError)
                end
              end

              context "and is invalid" do
                let(:start_time) { 3.days.from_now.to_time.iso8601 }

                it "raises an error" do
                  expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /must be after/)
                end
              end
            end

            context "with invalid end_time" do
              context "and is empty" do
                let(:end_time) { "" }

                it "raises an error" do
                  expect { response }.to raise_error(ArgumentError)
                end
              end

              context "and is invalid" do
                let(:end_time) { (2.days.ago + 2.hours).to_time.iso8601 }

                it "raises an error" do
                  expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /must be before/)
                end
              end
            end

            context "with empty fields" do
              context "when location" do
                let(:location) { "" }

                context "when online_meeting_url is required" do
                  let(:type_of_meeting) { "IN_PERSON" }

                  it "raises an error" do
                    expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
                  end
                end

                context "when online_meeting_url is optional" do
                  let(:type_of_meeting) { "ONLINE" }

                  it "saves the data" do
                    expect(response["update"]).to include({ "title" => { "translation" => title } })
                  end
                end
              end

              context "when address" do
                let(:address) { "" }

                context "when online_meeting_url is required" do
                  let(:type_of_meeting) { "IN_PERSON" }

                  it "raises an error" do
                    expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
                  end
                end

                context "when online_meeting_url is optional" do
                  let(:type_of_meeting) { "ONLINE" }

                  it "saves the data" do
                    expect(response["update"]).to include({ "title" => { "translation" => title } })
                  end
                end
              end
            end

            context "with empty online_meeting_url" do
              let(:online_meeting_url) { "" }

              context "when online_meeting_url is required" do
                let(:type_of_meeting) { "ONLINE" }

                it "raises an error" do
                  expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
                end
              end

              context "when online_meeting_url is optional" do
                let(:type_of_meeting) { "IN_PERSON" }

                it "saves the data" do
                  expect(response["update"]).to include({ "title" => { "translation" => title } })
                end
              end
            end
          end

          context "with partial update" do
            let(:variables) do
              {
                input: {
                  locale:,
                  attributes: {
                    description:,
                    endTime: end_time,
                    onlineMeetingUrl: online_meeting_url,
                    registrationType: registration_type,
                    startTime: start_time,
                    taxonomies: [taxonomy.id],
                    title: "Only title updated",
                    typeOfMeeting: type_of_meeting
                  }
                }
              }
            end

            it "updates only specified fields" do
              meeting_response = response["update"]
              expect(meeting_response).to be_present
              expect(meeting_response["title"]["translation"]).to eq("Only title updated")
            end
          end
        end
      end

      context "with user who owns the meeting" do
        it_behaves_like "update meeting mutation examples" do
          let!(:user_type) { :user }
        end
      end

      context "with admin user" do
        it_behaves_like "update meeting mutation examples" do
          let!(:user_type) { :admin }
        end
      end

      context "with api_user" do
        it_behaves_like "update meeting mutation examples" do
          let!(:user_type) { :api_user }
        end
      end

      context "with user who does not own the meeting" do
        let(:other_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:model) { create(:meeting, component: meeting_component, author: other_user) }

        it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
        end
      end
    end
  end
end
