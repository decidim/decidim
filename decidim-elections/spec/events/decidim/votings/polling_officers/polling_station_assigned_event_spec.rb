# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module PollingOfficers
      describe PollingStationAssignedEvent do
        include_context "when a simple event"

        let(:event_name) { "decidim.events.votings.polling_officers.polling_station_assigned" }
        let(:organization) { create(:organization) }
        let(:voting) { create(:voting, organization:) }
        let(:polling_station) { create(:polling_station, voting:) }
        let(:resource) { voting }
        let(:polling_officer) { create(:polling_officer, user:, managed_polling_station: polling_station, voting:) }
        let(:extra) { { polling_officer_id: polling_officer.id } }
        let(:polling_station_name) { translated(polling_station.title) }
        let(:voting_title) { translated(voting.title) }
        let(:voting_path) { "/votings/#{voting.slug}?voting_slug=#{voting.slug}" }
        let(:voting_url) { "http://#{organization.host}:#{Capybara.server_port}#{voting_path}" }
        let(:polling_officer_zone_url) { "http://#{organization.host}/polling_officers" }

        it_behaves_like "a simple event"

        describe "email_subject" do
          it "is generated correctly" do
            expect(subject.email_subject).to eq("You are Manager of the Polling Station #{polling_station_name}.")
          end
        end

        describe "email_intro" do
          it "is generated correctly" do
            expect(subject.email_intro)
              .to eq("You have been assigned as Manager of the Polling Station #{polling_station_name} in <a href=\"#{voting_url}\">#{voting_title}</a>. You can manage the Polling Station from the dedicated <a href=\"#{polling_officer_zone_url}\">Polling Officer Zone</a>.")
          end
        end

        describe "email_outro" do
          it "is generated correctly" do
            expect(subject.email_outro)
              .to eq("You have received this notification because you have been assigned as Manager of #{polling_station_name}.")
          end
        end

        describe "notification_title" do
          it "is generated correctly" do
            expect(subject.notification_title)
              .to eq("You are Manager of the Polling Station #{polling_station_name} in the voting <a href=\"#{voting_path}\">#{voting_title}</a>.")
          end
        end
      end
    end
  end
end
