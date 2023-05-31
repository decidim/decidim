# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Api
    describe ApplicationController, type: :controller do
      let(:utc_time_zone) { "UTC" }
      let(:alt_time_zone) { "Hawaii" }
      let(:organization) { create(:organization, time_zone:) }

      before do
        request.env["decidim.current_organization"] = organization
      end

      context "when time zone is UTC" do
        let(:time_zone) { utc_time_zone }

        it "controller uses UTC" do
          expect(controller.organization_time_zone).to eq(utc_time_zone)
        end

        it "Time uses UTC zone within the controller scope" do
          controller.use_organization_time_zone do
            expect(Time.zone.name).to eq(utc_time_zone)
          end
        end

        it "Time uses UTC outside the controller scope" do
          expect(Time.zone.name).to eq(utc_time_zone)
        end
      end

      context "when time zone is non-UTC" do
        let(:time_zone) { alt_time_zone }

        it "controller uses the custom time zone" do
          expect(controller.organization_time_zone).to eq(alt_time_zone)
        end

        it "Time uses configured time zone within the controller scope" do
          controller.use_organization_time_zone do
            expect(Time.zone.name).to eq(alt_time_zone)
          end
        end

        it "Time uses UTC outside the controller scope" do
          expect(Time.zone.name).to eq(utc_time_zone)
        end
      end

      context "when Rails is non-UTC", tz: "Azores" do
        context "and organizations uses UTC" do
          let(:time_zone) { utc_time_zone }

          it "controller uses UTC" do
            expect(controller.organization_time_zone).to eq(utc_time_zone)
          end

          it "Time uses UTC zone within the controller scope" do
            controller.use_organization_time_zone do
              expect(Time.zone.name).to eq(utc_time_zone)
            end
          end

          it "Time uses Rails timezone outside the controller scope" do
            expect(Time.zone.name).to eq("Azores")
          end
        end

        context "and organizations uses non-UTC" do
          let(:time_zone) { alt_time_zone }

          it "controller uses UTC" do
            expect(controller.organization_time_zone).to eq(alt_time_zone)
          end

          it "Time uses UTC zone within the controller scope" do
            controller.use_organization_time_zone do
              expect(Time.zone.name).to eq(alt_time_zone)
            end
          end

          it "Time uses Rails timezone outside the controller scope" do
            expect(Time.zone.name).to eq("Azores")
          end
        end
      end
    end
  end
end
