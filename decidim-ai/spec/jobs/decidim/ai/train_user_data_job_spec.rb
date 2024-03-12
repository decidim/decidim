# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ai
    describe TrainUserDataJob do
      subject { described_class }
      let(:organization) { create(:organization) }
      let(:about) { "This is a short info about me" }
      let!(:user) { create(:user, :confirmed, organization:, about:) }

      let(:backend) { ClassifierReborn::BayesMemoryBackend.new }

      let(:bayes_classifier) { ClassifierReborn::Bayes.new :spam, :ham, backend: }
      let(:algorithm) { Decidim::Ai::SpamDetection::Strategy::Bayes.new({}) }

      before do
        Decidim::Ai.spam_detection_registry.clear
        allow(algorithm).to receive(:backend).and_return(bayes_classifier)
        allow(Decidim::Ai.spam_detection_registry).to receive(:strategies).and_return([algorithm])
        Decidim::Ai.spam_detection_instance.train(:ham, about)
      end

      it "adds data to spam" do
        expect(backend.category_word_count(:ham)).to eq(3)
        expect(backend.category_word_count(:spam)).to eq(0)
        user.blocked = true
        user.save!
        subject.perform_now(user)
        expect(backend.category_word_count(:ham)).to eq(0)
        expect(backend.category_word_count(:spam)).to eq(3)
      end
    end
  end
end
