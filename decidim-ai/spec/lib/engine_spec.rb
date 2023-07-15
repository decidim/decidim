# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ai
    describe ".create_reporting_users" do
      let!(:organization) { create(:organization) }

      it "successfully creates user" do
        expect { Decidim::Ai.create_reporting_users! }.to change(Decidim::User, :count).by(1)
        expect(Decidim::User.where(email: Decidim::Ai.reporting_user_email).count).to eq(1)
      end

      it "ignores existing user" do
        Decidim::Ai.create_reporting_users!
        expect(Decidim::User.where(email: Decidim::Ai.reporting_user_email).count).to eq(1)
        expect { Decidim::Ai.create_reporting_users! }.not_to change(Decidim::User, :count)
        expect(Decidim::User.where(email: Decidim::Ai.reporting_user_email).count).to eq(1)
      end

      it "creates users for all organizations" do
        create_list(:organization, 2)
        expect { Decidim::Ai.create_reporting_users! }.to change(Decidim::User, :count).by(3)
      end
    end
  end
end
