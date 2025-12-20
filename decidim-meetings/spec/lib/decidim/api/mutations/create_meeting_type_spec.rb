# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Meetings
    describe CreateMeetingType do
      include_context "with a graphql class type"

      let(:schema) { Decidim::Api::Schema }
      let(:locale) { "en" }
      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:component) { create(:component, participatory_space: participatory_process, manifest_name: "meetings") }
      let(:current_user) { create(:user, :confirmed, organization:) }
      let(:context) do
        {
          current_user:,
          current_organization: organization
        }
      end

      let(:start_time) { 1.day.from_now }
      let(:end_time) { start_time + 2.hours }

      let(:meeting_attributes) do
        {
          title: "Test Meeting",
          description: "This is a test meeting",
          location: "Test Location",
          location_hints: "Near the main square",
          type_of_meeting: "online",
          start_time: start_time.iso8601,
          end_time: end_time.iso8601,
          registration_type: "on_this_platform",
          available_slots: 50,
          registration_terms: "Please be on time",
          online_meeting_url: "https://meet.example.com/test",
          iframe_embed_type: "embed_in_meeting_page",
          iframe_access_level: "all"
        }
      end

      let(:mutation) do
        %(
          mutation {
            createMeeting(
              componentId: #{component.id},
              attributes: {
                title: "#{meeting_attributes[:title]}",
                description: "#{meeting_attributes[:description]}",
                location: "#{meeting_attributes[:location]}",
                locationHints: "#{meeting_attributes[:location_hints]}",
                typeOfMeeting: "#{meeting_attributes[:type_of_meeting]}",
                startTime: "#{meeting_attributes[:start_time]}",
                endTime: "#{meeting_attributes[:end_time]}",
                registrationType: "#{meeting_attributes[:registration_type]}",
                availableSlots: #{meeting_attributes[:available_slots]},
                registrationTerms: "#{meeting_attributes[:registration_terms]}",
                onlineMeetingUrl: "#{meeting_attributes[:online_meeting_url]}",
                iframeEmbedType: "#{meeting_attributes[:iframe_embed_type]}",
                iframeAccessLevel: "#{meeting_attributes[:iframe_access_level]}"
              }
            ) {
              id
              title { translation(locale: "en") }
              description { translation(locale: "en") }
              typeOfMeeting
              startTime
              endTime
            }
          }
        )
      end

      describe "createMeeting mutation" do
        context "when user is authorized" do
          before do
            allow(context).to receive(:[]).with(:current_user).and_return(current_user)
            allow(context).to receive(:[]).with(:current_organization).and_return(organization)

            # Grant permission to create meetings
            Decidim::PermissionAction.new(action: :create, subject: :meeting, scope: :public)
            allow_any_instance_of(Decidim::Meetings::Permissions).to receive(:allowed?).and_return(true)
            allow_any_instance_of(CreateMeetingType).to receive(:allowed_to?).and_return(true)
          end

          it "creates a meeting successfully" do
            result = schema.execute(
              mutation,
              context:,
              variables: {}
            )

            expect(result["errors"]).to be_nil
            expect(result.dig("data", "createMeeting")).to be_present
            expect(result.dig("data", "createMeeting", "title", "translation")).to eq(meeting_attributes[:title])
            expect(result.dig("data", "createMeeting", "typeOfMeeting")).to eq(meeting_attributes[:type_of_meeting])
          end

          it "increases the meeting count" do
            expect do
              schema.execute(
                mutation,
                context:,
                variables: {}
              )
            end.to change(Meeting, :count).by(1)
          end

          context "when meeting attributes are invalid" do
            let(:meeting_attributes) do
              {
                title: "",
                description: "Test",
                type_of_meeting: "online",
                start_time: start_time.iso8601,
                end_time: (start_time - 1.hour).iso8601, # Invalid: end before start
                registration_type: "on_this_platform"
              }
            end

            let(:mutation) do
              %(
                mutation {
                  createMeeting(
                    componentId: #{component.id},
                    attributes: {
                      title: "",
                      description: "#{meeting_attributes[:description]}",
                      typeOfMeeting: "#{meeting_attributes[:type_of_meeting]}",
                      startTime: "#{meeting_attributes[:start_time]}",
                      endTime: "#{meeting_attributes[:end_time]}",
                      registrationType: "#{meeting_attributes[:registration_type]}"
                    }
                  ) {
                    id
                  }
                }
              )
            end

            it "returns validation errors" do
              result = schema.execute(
                mutation,
                context:,
                variables: {}
              )

              expect(result["errors"]).to be_present
              expect(result["errors"].first["message"]).to include("Title")
            end
          end
        end

        context "when user is not authorized" do
          it "returns an authorization error" do
            result = schema.execute(
              mutation,
              context: { current_user: nil, current_organization: organization },
              variables: {}
            )

            expect(result["errors"]).to be_present
          end
        end

        context "when component does not exist" do
          let(:mutation) do
            %(
              mutation {
                createMeeting(
                  componentId: 999999,
                  attributes: {
                    title: "Test",
                    description: "Test",
                    typeOfMeeting: "online",
                    startTime: "#{start_time.iso8601}",
                    endTime: "#{end_time.iso8601}",
                    registrationType: "registration_disabled"
                  }
                ) {
                  id
                }
              }
            )
          end

          before do
            allow(context).to receive(:[]).with(:current_user).and_return(current_user)
            allow(context).to receive(:[]).with(:current_organization).and_return(organization)
          end

          it "returns an error" do
            result = schema.execute(
              mutation,
              context:,
              variables: {}
            )

            expect(result["errors"]).to be_present
          end
        end
      end
    end
  end
end
