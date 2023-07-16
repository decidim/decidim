# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ai
    describe ".language_detection_service" do
      subject { Decidim::Ai.language_detection_service.constantize.new("This is a test") }

      it "returns a language detection service" do
        expect(subject).to be_a(Decidim::Ai::LanguageDetectionService)
      end

      it "returns the corect language code" do
        expect(subject.language_code).to eq("en")
      end
    end

    describe ".spam_detection_strategy" do
      it "return strategy class" do
        expect(Decidim::Ai.spam_detection_strategy).to be_a(Decidim::Ai::StrategyRegistry)
      end
    end

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
