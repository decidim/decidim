# frozen_string_literal: true

require "spec_helper"

module Decidim::Abilities
  describe BaseAbility do
    let(:user) { build(:user) }
    subject { described_class.new(user, {}) }

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

    context "abilities" do
      context "own authorizations" do
        let(:authorization) { build(:authorization, user: user) }

        it { is_expected.to be_able_to(:manage, authorization) }
        it { is_expected.to be_able_to(:manage, Decidim::Authorization) }
      end

      context "other authorizations" do
        let(:authorization) { build(:authorization) }

        it { is_expected.not_to be_able_to(:manage, authorization) }
      end
    end
  end
end
