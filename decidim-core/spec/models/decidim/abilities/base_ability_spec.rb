# frozen_string_literal: true

require "spec_helper"

module Decidim::Abilities
  describe BaseAbility do
    subject { described_class.new(user, {}) }

    let(:user) { build(:user) }

    context "when there are some abilities injected from configuration" do
      class FakeAbility
        include CanCan::Ability

        def initialize(_user, _context)
          can :read, Decidim::Feature
        end
      end

      let(:abilities) { ["Decidim::Abilities::FakeAbility"] }

      before do
        allow(Decidim)
          .to receive(:abilities)
          .and_return(abilities)
      end

      it { is_expected.to be_able_to(:read, Decidim::Feature) }
    end

    describe "abilities" do
      context "when own authorizations" do
        context "when not yet authorized" do
          let!(:authorization) { build(:authorization, user: user) }

          it { is_expected.to be_able_to(:create, authorization) }
          it { is_expected.not_to be_able_to(:update, authorization) }
        end

        context "when authorization in process" do
          let!(:authorization) { create(:authorization, :pending, name: "dummy", user: user) }
          let!(:other_authorization) { build(:authorization, :pending, name: "dummy", user: user) }

          it { is_expected.not_to be_able_to(:create, other_authorization) }
          it { is_expected.to be_able_to(:update, authorization) }
        end

        context "when authorization already granted" do
          let!(:authorization) { create(:authorization, :granted, name: "dummy", user: user) }
          let!(:other_authorization) { build(:authorization, name: "dummy", user: user) }

          it { is_expected.not_to be_able_to(:create, other_authorization) }
          it { is_expected.not_to be_able_to(:update, authorization) }
        end
      end

      context "when authorizations from others" do
        let(:authorization) { build(:authorization) }

        it { is_expected.not_to be_able_to(:create, authorization) }
        it { is_expected.not_to be_able_to(:update, authorization) }
      end
    end
  end
end
