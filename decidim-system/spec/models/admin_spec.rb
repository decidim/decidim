# frozen_string_literal: true
require "spec_helper"

module Decidim
  module System
    describe Admin, :db do
      let(:admin) { build(:admin) }

      it "is valid" do
        expect(admin).to be_valid
      end

      context "devise emails" do
        let(:admin) { create(:admin) }

        it "sends them asynchronously" do
          described_class.send_reset_password_instructions(email: admin.email)
          expect(ActionMailer::DeliveryJob).to have_been_enqueued.on_queue("mailers")
        end
      end
    end
  end
end
