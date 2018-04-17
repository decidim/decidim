# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Abilities
      describe EveryoneAbility do
        subject { described_class.new(user, {}) }

        context "when admin user" do
          let(:user) { build(:user, :admin) }

          context "and published consultation" do
            let(:consultation) { build(:consultation, :published, organization: user.organization) }

            it { is_expected.to be_able_to(:read, consultation) }
          end

          context "and unpublished consultation" do
            let(:consultation) { build(:consultation, :unpublished, organization: user.organization) }

            it { is_expected.to be_able_to(:read, consultation) }
          end

          context "and publised question" do
            let(:consultation) { create(:consultation, organization: user.organization) }
            let(:question) { build(:question, :published, consultation: consultation) }

            it { is_expected.to be_able_to(:read, question) }
          end

          context "and unpublised question" do
            let(:consultation) { create(:consultation, organization: user.organization) }
            let(:question) { build(:question, :unpublished, consultation: consultation) }

            it { is_expected.to be_able_to(:read, question) }
          end
        end

        context "when regular user" do
          let(:user) { build(:user) }

          context "and published consultation" do
            let(:consultation) { build(:consultation, :published, organization: user.organization) }

            it { is_expected.to be_able_to(:read, consultation) }
          end

          context "and unpublished consultation" do
            let(:consultation) { build(:consultation, :unpublished, organization: user.organization) }

            it { is_expected.not_to be_able_to(:read, consultation) }
          end

          context "and publised question" do
            let(:consultation) { create(:consultation, organization: user.organization) }
            let(:question) { build(:question, :published, consultation: consultation) }

            it { is_expected.to be_able_to(:read, question) }
          end

          context "and unpublised question" do
            let(:consultation) { create(:consultation, organization: user.organization) }
            let(:question) { build(:question, :unpublished, consultation: consultation) }

            it { is_expected.not_to be_able_to(:read, question) }
          end
        end

        context "when guest user" do
          let(:user) { nil }

          context "and published consultation" do
            let(:consultation) { build(:consultation, :published) }

            it { is_expected.to be_able_to(:read, consultation) }
          end

          context "and unpublished consultation" do
            let(:consultation) { build(:consultation, :unpublished) }

            it { is_expected.not_to be_able_to(:read, consultation) }
          end

          context "and publised question" do
            let(:consultation) { create(:consultation) }
            let(:question) { build(:question, :published, consultation: consultation) }

            it { is_expected.to be_able_to(:read, question) }
          end

          context "and unpublised question" do
            let(:consultation) { create(:consultation) }
            let(:question) { build(:question, :unpublished, consultation: consultation) }

            it { is_expected.not_to be_able_to(:read, question) }
          end
        end
      end
    end
  end
end
