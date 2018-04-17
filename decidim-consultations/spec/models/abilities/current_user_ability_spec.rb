# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Abilities
      describe CurrentUserAbility do
        subject { described_class.new(user, {}) }

        let(:organization) { create :organization }
        let(:user) { create(:user, organization: organization) }
        let(:consultation) { create :consultation, :published, :active, organization: organization }
        let(:question) { create :question, :published, consultation: consultation }

        context "when authenticated user" do
          it { is_expected.to be_able_to(:vote, question) }

          context "and unpublished question" do
            let(:question) { create :question, :unpublished, consultation: consultation }

            it { is_expected.not_to be_able_to(:vote, question) }
          end

          context "and unpublished consultation" do
            let(:consultation) { create :consultation, :unpublished, :active, organization: organization }

            it { is_expected.not_to be_able_to(:vote, question) }
          end

          context "and upcoming consultation" do
            let(:consultation) { create :consultation, :published, :upcoming, organization: organization }

            it { is_expected.not_to be_able_to(:vote, question) }
          end

          context "and finished consultation" do
            let(:consultation) { create :consultation, :published, :finished, organization: organization }

            it { is_expected.not_to be_able_to(:vote, question) }
          end

          context "and previously voted question" do
            let!(:vote) { create :vote, author: user, question: question }

            it { is_expected.not_to be_able_to(:vote, question) }
            it { is_expected.to be_able_to(:unvote, question) }
          end
        end

        context "when user of different organization" do
          let(:user) { create(:user) }

          it { is_expected.not_to be_able_to(:vote, question) }
        end

        context "when guest user" do
          let(:user) { nil }
          let(:consultation) { create(:consultation, :published, :active) }
          let(:question) { create(:question, consultation: consultation) }

          it { is_expected.not_to be_able_to(:vote, question) }
          it { is_expected.not_to be_able_to(:unvote, question) }
        end
      end
    end
  end
end
