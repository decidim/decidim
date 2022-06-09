# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe UpdatePollingStation do
        let(:polling_station) { create :polling_station }
        let!(:president) { create :polling_officer, voting: polling_station.voting, presided_polling_station: polling_station }
        let!(:managers) { create_list :polling_officer, 3, voting: polling_station.voting, managed_polling_station: polling_station }

        let(:updated_president) { create :polling_officer, voting: polling_station.voting, presided_polling_station: nil }
        let(:updated_managers) { create_list :polling_officer, 3, voting: polling_station.voting, managed_polling_station: nil }
        let(:params) do
          {
            polling_station: {
              id: polling_station.id,
              title_en: "Updated title",
              title_ca: "Título actualizado",
              title_es: "Títol actualitzat",
              location_en: "Updated location",
              location_es: "Location actualizada",
              location_ca: "Location actualitzada",
              location_hints_en: "Updated location hints",
              location_hints_es: "Location hints actualizados",
              location_hints_ca: "Location hints actualitzats",
              address: "Updated address",
              latitude: 40.123,
              longitude: 7.321,
              voting: polling_station.voting,
              polling_station_president_id: updated_president&.id,
              polling_station_manager_ids: updated_managers.pluck(:id)
            }
          }
        end
        let(:context) do
          {
            current_organization: polling_station.voting.organization
          }
        end
        let(:form) { PollingStationForm.from_params(params).with_context(context) }

        subject { described_class.new(form, polling_station) }

        context "when the form is not valid" do
          let(:params) { { address: nil } }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "doesn't update the polling station" do
            subject.call
            polling_station.reload

            expect(polling_station.title["en"]).not_to eq("Updated title")
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "updates the polling station title" do
            expect { subject.call }.to broadcast(:ok)
            polling_station.reload

            expect(polling_station.title["en"]).to eq("Updated title")
          end

          it "updates the polling station location" do
            expect { subject.call }.to broadcast(:ok)
            polling_station.reload

            expect(polling_station.location["es"]).to eq("Location actualizada")
          end

          it "updates the polling station location hints" do
            expect { subject.call }.to broadcast(:ok)
            polling_station.reload

            expect(polling_station.location_hints["ca"]).to eq("Location hints actualitzats")
          end

          it "updates the polling station address" do
            expect { subject.call }.to broadcast(:ok)
            polling_station.reload

            expect(polling_station.address).to eq("Updated address")
          end

          context "when updating the polling station president" do
            let(:updated_managers) { [] }

            context "when the president is nil" do
              let(:updated_president) { nil }

              it "unussigns the president" do
                expect { subject.call }.to broadcast(:ok)
                expect(president.reload.presided_polling_station).to be_nil
                expect(polling_station.reload.polling_station_president).to be_nil
              end
            end

            context "when there's a new president" do
              it "assigns the new president" do
                expect { subject.call }.to broadcast(:ok)
                expect(updated_president.reload.presided_polling_station).to eq polling_station
                expect(president.reload.presided_polling_station).to be_nil
                expect(polling_station.reload.polling_station_president).to eq updated_president
              end

              it "notifies the new president" do
                expect(Decidim::EventsManager)
                  .to receive(:publish)
                  .with(
                    event: "decidim.events.votings.polling_officers.polling_station_assigned",
                    event_class: PollingOfficers::PollingStationAssignedEvent,
                    resource: polling_station.voting,
                    affected_users: [updated_president.user],
                    followers: [],
                    extra: { polling_officer_id: updated_president.id }
                  )

                expect { subject.call }.to broadcast(:ok)
              end
            end
          end

          context "when updating the polling station managers" do
            let(:updated_president) { nil }

            context "when the are no managers" do
              let(:updated_managers) { [] }

              it "unussigns all the managers" do
                expect { subject.call }.to broadcast(:ok)
                polling_station.reload
                expect(polling_station.polling_station_managers.count).to eq updated_managers.count
                managers.each do |manager|
                  expect(manager.reload.managed_polling_station).to be_nil
                end
                expect(polling_station.polling_station_managers).to be_empty
              end
            end

            context "when the managers are all new" do
              it "assigns the new managers" do
                expect { subject.call }.to broadcast(:ok)
                polling_station.reload
                expect(polling_station.polling_station_managers.count).to eq updated_managers.count
                updated_managers.each do |updated_manager|
                  expect(updated_manager.reload.managed_polling_station).to eq polling_station
                  expect(polling_station.polling_station_managers).to include(updated_manager)
                end
                managers.each do |manager|
                  expect(manager.reload.managed_polling_station).to be_nil
                  expect(polling_station.polling_station_managers).not_to include(manager)
                end
              end

              it "notifies the new managers" do
                updated_managers.each do |updated_manager|
                  expect(Decidim::EventsManager)
                    .to receive(:publish)
                    .with(
                      event: "decidim.events.votings.polling_officers.polling_station_assigned",
                      event_class: PollingOfficers::PollingStationAssignedEvent,
                      resource: polling_station.voting,
                      affected_users: [updated_manager.user],
                      followers: [],
                      extra: { polling_officer_id: updated_manager.id }
                    )
                end

                expect { subject.call }.to broadcast(:ok)
              end
            end

            context "when there managers are added and removed" do
              let(:old_manager) { managers.first }
              let(:new_manager) { create(:polling_officer, voting: polling_station.voting) }
              let(:updated_managers) { [old_manager, new_manager] }

              it "assigns the added managers and unussigns the removed ones" do
                expect { subject.call }.to broadcast(:ok)
                polling_station.reload
                expect(polling_station.polling_station_managers.count).to eq updated_managers.count
                updated_managers.each do |updated_manager|
                  expect(updated_manager.reload.managed_polling_station).to eq polling_station
                  expect(polling_station.polling_station_managers).to include(updated_manager)
                end
              end

              it "notifies the new managers" do
                expect(Decidim::EventsManager)
                  .to receive(:publish)
                  .with(
                    event: "decidim.events.votings.polling_officers.polling_station_assigned",
                    event_class: PollingOfficers::PollingStationAssignedEvent,
                    resource: polling_station.voting,
                    affected_users: [new_manager.user],
                    followers: [],
                    extra: { polling_officer_id: new_manager.id }
                  )

                expect { subject.call }.to broadcast(:ok)
              end
            end
          end
        end
      end
    end
  end
end
