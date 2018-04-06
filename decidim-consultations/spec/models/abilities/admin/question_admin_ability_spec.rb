# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Abilities
      module Admin
        describe QuestionAdminAbility do
          subject { described_class.new(user, {}) }

          context "when admin user" do
            let(:user) { build(:user, :admin) }

            it { is_expected.to be_able_to(:manage, Decidim::Consultations::Question) }

            context "and external voting system" do
              let(:question) { create :question, :unpublished, :external_voting }

              it { is_expected.to be_able_to :publish, question }
            end

            context "and unpublished question" do
              let(:question) { create :question, :unpublished }

              context "and no responses defined" do
                it { is_expected.not_to be_able_to :publish, question }
              end

              context "and responses defined" do
                let!(:response) { create :response, question: question }

                it { is_expected.to be_able_to :publish, question }
              end
            end
          end

          context "when regular user" do
            let(:user) { build(:user) }

            it { is_expected.not_to be_able_to(:manage, Decidim::Consultations::Question) }
          end

          context "when guest user" do
            let(:user) { nil }

            it { is_expected.not_to be_able_to(:manage, Decidim::Consultations::Question) }
          end
        end
      end
    end
  end
end
