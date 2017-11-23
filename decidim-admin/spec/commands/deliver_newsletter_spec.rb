# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe DeliverNewsletter do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:newsletter) do
        create(:newsletter,
               organization: organization,
               body: Decidim::Faker::Localized.sentence(3))
      end

      let!(:deliverable_users) do
        create_list(:user, 5, :confirmed, organization: organization, newsletter_notifications: true)
      end

      let!(:not_deliverable_users) do
        create_list(:user, 3, organization: organization, newsletter_notifications: false)
      end
      let!(:unconfirmed_users) do
        create_list(:user, 3, organization: organization, newsletter_notifications: true)
      end

      let(:command) { described_class.new(newsletter) }

      it "updates the counters and delivers to the right users" do
        clear_emails
        expect(emails.length).to eq(0)

        perform_enqueued_jobs { command.call }

        expect(emails.length).to eq(5)

        deliverable_users.each do |user|
          email = emails.find { |e| e.to.include? user.email }
          expect(email_body(email)).to include(newsletter.body[user.locale])
        end

        newsletter.reload
        expect(newsletter.total_deliveries).to eq(5)
        expect(newsletter.total_recipients).to eq(5)
      end
    end
  end
end
