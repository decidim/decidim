# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe UpdatePollingStation do
        let(:polling_station) { create :polling_station }
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
              voting: polling_station.voting
            }
          }
        end
        let(:context) do
          {
            current_organization: polling_station.voting.organization
          }
        end
        let(:form) { PollingStationForm.from_params(params).with_context(context) }
        let(:subject) { described_class.new(form, polling_station) }

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
        end
      end
    end
  end
end
