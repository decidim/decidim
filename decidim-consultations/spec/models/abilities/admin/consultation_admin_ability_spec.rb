# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Abilities
      module Admin
        describe ConsultationAdminAbility do
          subject { described_class.new(user, {}) }

          context "when admin user" do
            let(:user) { build(:user, :admin) }

            it { is_expected.to be_able_to(:manage, Decidim::Consultation) }
          end

          context "when regular user" do
            let(:user) { build(:user) }

            it { is_expected.not_to be_able_to(:manage, Decidim::Consultation) }
          end

          context "when guest user" do
            let(:user) { nil }

            it { is_expected.not_to be_able_to(:manage, Decidim::Consultation) }
          end

          context "when managing publishing results" do
            let(:consultation) { build :consultation, :finished, :unpublished_results }

            context "and admin user" do
              let(:user) { build(:user, :admin) }

              it { is_expected.to be_able_to(:publish_results, consultation) }

              context "and unfinished consultation" do
                let(:consultation) { build :consultation, :active, :unpublished_results }

                it { is_expected.not_to be_able_to(:publish_results, consultation) }
              end

              context "and published results consultation" do
                let(:consultation) { build :consultation, :active, :published_results }

                it { is_expected.not_to be_able_to(:publish_results, consultation) }
              end
            end

            context "when regular user" do
              let(:user) { build(:user) }

              it { is_expected.not_to be_able_to(:publish_results, consultation) }
            end

            context "when guest user" do
              let(:user) { nil }

              it { is_expected.not_to be_able_to(:publish_results, consultation) }
            end
          end

          context "when managing unpublishing results" do
            let(:consultation) { build :consultation, :published_results }

            context "and admin user" do
              let(:user) { build(:user, :admin) }

              it { is_expected.to be_able_to(:unpublish_results, consultation) }

              context "and unpublished results consultation" do
                let(:consultation) { build :consultation, :unpublished_results }

                it { is_expected.not_to be_able_to(:unpublish_results, consultation) }
              end
            end

            context "when regular user" do
              let(:user) { build(:user) }

              it { is_expected.not_to be_able_to(:unpublish_results, consultation) }
            end

            context "when guest user" do
              let(:user) { nil }

              it { is_expected.not_to be_able_to(:unpublish_results, consultation) }
            end
          end
        end
      end
    end
  end
end
