# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationToMailerPresenter, type: :presenter do
    let(:creating_date) { Time.parse("Wed, 1 Sep 2021 21:00:00 UTC +00:00").in_time_zone }
    let(:notification) { create(:notification, created_at: creating_date) }

    subject { described_class.new(notification) }

    context "with a daily frequency" do
      describe "#date_time" do
        it "returns the hour formated" do
          allow(subject).to receive(:frequency).and_return(:daily)
          expect(subject.date_time).to eq("21:00")
        end
      end

      describe "#resource_title" do
        it "returns the resource title sanitized" do
          expect(subject.resource_title).to eq(decidim_sanitize_translated(notification.resource.title))
        end
      end

      describe "#resource_url" do
        it "returns the resource url" do
          expect(subject.resource_url).to eq(resource_locator(notification.resource).url)
          expect(subject.resource_path).to eq(resource_locator(notification.resource).path)
        end
      end

      describe "#email_intro" do
        it "returns the email intro" do
          expect(subject.email_intro).to include(decidim_sanitize_translated(notification.resource.title))
        end

        context "when the notification event does not send emails" do
          let(:notification) { create(:notification, event_class: "Decidim::Dev::DummyNotificationOnlyResourceEvent") }

          it "returns nil" do
            expect(subject.email_intro).to be_nil
          end
        end
      end
    end

    context "with a daily frequency in different timezone" do
      let(:notification) do
        create(:notification, created_at: creating_date) do |notification|
          org = notification.resource.organization
          org.time_zone = "Asia/Tokyo"
          org.save!
        end
      end

      describe "#date_time" do
        it "returns the hour formated" do
          allow(subject).to receive(:frequency).and_return(:daily)
          expect(subject.date_time).to eq("06:00")
        end
      end
    end

    context "with a weekly frequency" do
      describe "#date_time" do
        it "returns the date formated" do
          allow(subject).to receive(:frequency).and_return(:weekly)
          expect(subject.date_time).to eq("01/09/2021 21:00")
        end
      end
    end

    context "with a weekly frequency in different timezone" do
      let(:notification) do
        create(:notification, created_at: creating_date) do |notification|
          org = notification.resource.organization
          org.time_zone = "Asia/Tokyo"
          org.save!
        end
      end

      describe "#date_time" do
        it "returns the hour formated" do
          allow(subject).to receive(:frequency).and_return(:weekly)
          expect(subject.date_time).to eq("02/09/2021 06:00")
        end
      end
    end
  end
end
