# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe CreatePollingStation do
        subject { described_class.new(form) }

        let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
        let(:user) { create :user, :admin, :confirmed, organization: organization }
        let(:voting) { create :voting, voting_type: "hybrid", organization: organization }
        let(:president) { nil }
        let(:managers) { [] }

        let(:form) do
          double(
            invalid?: invalid,
            title: title,
            location: location,
            location_hints: location_hints,
            address: address,
            latitude: latitude,
            longitude: longitude,
            polling_station_president: president,
            polling_station_president_id: president&.id,
            polling_station_managers: managers,
            polling_station_manager_ids: managers.pluck(:id),
            current_user: user,
            current_organization: organization,
            voting: voting
          )
        end

        let(:title) { { en: "Polling Station Deluxe" } }
        let(:location) { { en: "A nice location" } }
        let(:location_hints) { { en: "Catch me if you can" } }
        let(:invalid) { false }
        let(:address) { "address" }
        let(:latitude) { 40.1234 }
        let(:longitude) { 2.1234 }

        let(:polling_station) { Decidim::Votings::PollingStation.last }

        it "creates the voting" do
          expect { subject.call }.to change(Decidim::Votings::PollingStation, :count).by(1)
        end

        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "stores the given data" do
          subject.call
          expect(translated(polling_station.title)).to eq title[:en]
          expect(translated(polling_station.location)).to eq location[:en]
          expect(translated(polling_station.location_hints)).to eq location_hints[:en]
          expect(polling_station.address).to eq address
          expect(polling_station.latitude).to eq latitude
          expect(polling_station.longitude).to eq longitude
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:create!)
            .with(
              Decidim::Votings::PollingStation,
              user,
              kind_of(Hash),
              visibility: "all"
            )
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.version.event).to eq "create"
        end

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when selecting a president" do
          let(:president) { create(:polling_officer, voting: voting) }

          it "stores the reference correctly" do
            subject.call

            expect(president.reload.presided_polling_station).to eq polling_station
            expect(polling_station.reload.polling_station_president).to eq president
          end

          it "notifies the president" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.votings.polling_officers.polling_station_assigned",
                event_class: PollingOfficers::PollingStationAssignedEvent,
                resource: voting,
                affected_users: [president.user],
                followers: [],
                extra: { polling_officer_id: president.id }
              )

            subject.call
          end
        end

        context "when selecting managers" do
          let(:managers) { create_list(:polling_officer, 3, voting: voting) }

          it "stores the reference correctly" do
            subject.call

            managers.each do |manager|
              expect(manager.reload.managed_polling_station).to eq polling_station
              expect(polling_station.reload.polling_station_managers).to include(manager)
            end
          end

          it "notifies the manmagers" do
            managers.each do |manager|
              expect(Decidim::EventsManager)
                .to receive(:publish)
                .with(
                  event: "decidim.events.votings.polling_officers.polling_station_assigned",
                  event_class: PollingOfficers::PollingStationAssignedEvent,
                  resource: voting,
                  affected_users: [manager.user],
                  followers: [],
                  extra: { polling_officer_id: manager.id }
                )
            end

            subject.call
          end
        end
      end
    end
  end
end
