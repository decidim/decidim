# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe NewsletterDeliveryJob do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }
      let(:newsletter) { create(:newsletter, organization:, total_deliveries: 0) }

      it "delivers the email" do
        expect(ActionMailer::Base.deliveries).to be_empty
        NewsletterDeliveryJob.perform_now(user, newsletter)
        expect(ActionMailer::Base.deliveries).not_to be_empty
      end

      context "when the user is deleted" do
        let(:user) { create(:user, :deleted) }

        it "does not deliver the email" do
          expect(ActionMailer::Base.deliveries).to be_empty
          NewsletterDeliveryJob.perform_now(user, newsletter)
          expect(ActionMailer::Base.deliveries).to be_empty
        end
      end

      it "delivers a newsletter to a single user" do
        NewsletterDeliveryJob.perform_now(user, newsletter)

        expect(last_email.subject).to include(newsletter.subject[I18n.locale.to_s])
        expect(last_email.to).to include(user.email)
      end

      it "increments the delivery count" do
        expect do
          NewsletterDeliveryJob.perform_now(user, newsletter)
        end.to change { newsletter.reload.total_deliveries }.by(1)
      end
    end
  end
end
