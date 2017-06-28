# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe NewsletterJob do
      let!(:newsletter) { create(:newsletter, organization: organization, total_deliveries: 0) }
      let!(:organization) { create(:organization) }
      let!(:another_organization) { create(:organization) }
      let!(:deliverable_user) { create(:user, :confirmed, newsletter_notifications: true, organization: organization) }
      let!(:another_deliverable_user) { create(:user, :confirmed, newsletter_notifications: true, organization: another_organization) }
      let!(:undeliverable_user) { create(:user, newsletter_notifications: true, organization: organization) }
      let!(:non_deliverable_user) { create(:user, :confirmed, newsletter_notifications: false, organization: organization) }
      let!(:deleted_user) { create(:user, :confirmed, :deleted, newsletter_notifications: true, organization: organization) }

      it "delivers a newsletter to a the eligible users" do
        expect(NewsletterDeliveryJob).to receive(:perform_later).with(deliverable_user, newsletter)
        expect(NewsletterDeliveryJob).not_to receive(:perform_later).with(undeliverable_user, newsletter)

        NewsletterJob.perform_now(newsletter)
      end

      it "updates the recipients count" do
        NewsletterJob.perform_now(newsletter)
        expect(newsletter.reload.total_recipients).to eq(1)
      end

      it "updates the deliveries count" do
        NewsletterJob.perform_now(newsletter)
        expect(newsletter.reload.total_deliveries).to eq(0)
      end
    end
  end
end
