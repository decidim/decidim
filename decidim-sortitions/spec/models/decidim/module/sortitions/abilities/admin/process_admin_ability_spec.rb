# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    module Abilities
      module Admin
        describe ProcessAdminAbility do
          subject { described_class.new(user, context) }

          let(:participatory_process) { create :participatory_process }
          let(:context) do
            {
              current_participatory_space: participatory_process
            }
          end
          let(:user) { create :process_admin, participatory_process: participatory_process }

          it { is_expected.to be_able_to(:manage, Decidim::Sortitions::Sortition) }

          describe "Destroy sortition" do
            let(:sortition) { build(:sortition, cancelled_on: cancelled_on) }

            context "when active sortition" do
              let(:cancelled_on) { nil }

              it { is_expected.to be_able_to(:destroy, sortition) }
            end

            context "when cancelled sortition" do
              let(:cancelled_on) { Time.now.utc }

              it { is_expected.not_to be_able_to(:destroy, sortition) }
            end
          end
        end
      end
    end
  end
end
