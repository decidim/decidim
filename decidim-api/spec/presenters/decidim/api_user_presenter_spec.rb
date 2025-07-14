# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Api::ApiUserPresenter, type: :helper do
    let(:presenter) { described_class.new(user) }
    let(:user) { build(:api_user) }

    describe "#can_be_contacted?" do
      subject { described_class.new(user).can_be_contacted? }

      it "cannot be contacted" do
        expect(subject).to be(false)
      end
    end

    describe "#can_follow?" do
      subject { described_class.new(user).can_follow? }

      it "cannot follow" do
        expect(subject).to be(false)
      end
    end

    describe "#badge" do
      subject { described_class.new(user).badge }

      it "has verified badge" do
        expect(subject).to eq("verified-badge")
      end
    end
  end
end
