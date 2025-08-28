# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe LikeableHelper do
    describe "likes enabled" do
      subject { helper.likes_enabled? }

      before do
        allow(helper).to receive(:current_settings).and_return(double(likes_enabled:))
      end

      context "when likes are enabled" do
        let(:likes_enabled) { true }

        it { is_expected.to be true }
      end

      context "when likes are NOT enabled" do
        let(:likes_enabled) { false }

        it { is_expected.to be false }
      end
    end

    describe "likes blocked" do
      subject { helper.likes_blocked? }

      before do
        allow(helper).to receive(:current_settings).and_return(double(likes_blocked:))
      end

      context "when likes are blocked" do
        let(:likes_blocked) { true }

        it { is_expected.to be true }
      end

      context "when likes are NOT blocked" do
        let(:likes_blocked) { false }

        it { is_expected.to be false }
      end
    end
  end
end
