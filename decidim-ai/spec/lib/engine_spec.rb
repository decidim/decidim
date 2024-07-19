# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ai
    describe ".spam_detection_service" do
      subject { Decidim::Ai.spam_detection_instance }

      it "returns a spam detection service" do
        expect(subject).to be_a(Decidim::Ai::SpamDetection::Service)
      end
    end

    describe ".language_detection_service" do
      subject { Decidim::Ai::LanguageDetection.service.new("This is a test") }

      it "returns a language detection service" do
        expect(subject).to be_a(Decidim::Ai::LanguageDetection::Service)
      end

      it "returns the correct language code" do
        expect(subject.language_code).to eq("en")
      end
    end

    describe ".spam_detection_strategy" do
      it "return strategy class" do
        expect(Decidim::Ai.spam_detection_registry).to be_a(Decidim::Ai::StrategyRegistry)
      end
    end

    describe ".create_reporting_users" do
      let!(:organization) { create(:organization) }

      it "successfully creates user" do
        expect { Decidim::Ai::SpamDetection.create_reporting_user! }.to change(Decidim::User, :count).by(1)
        expect(Decidim::User.where(email: Decidim::Ai::SpamDetection.reporting_user_email).count).to eq(1)
      end

      it "ignores existing user" do
        Decidim::Ai::SpamDetection.create_reporting_user!
        expect(Decidim::User.where(email: Decidim::Ai::SpamDetection.reporting_user_email).count).to eq(1)
        expect { Decidim::Ai::SpamDetection.create_reporting_user! }.not_to change(Decidim::User, :count)
        expect(Decidim::User.where(email: Decidim::Ai::SpamDetection.reporting_user_email).count).to eq(1)
      end

      it "creates users for all organizations" do
        create_list(:organization, 2)
        expect { Decidim::Ai::SpamDetection.create_reporting_user! }.to change(Decidim::User, :count).by(3)
      end
    end
  end
end
