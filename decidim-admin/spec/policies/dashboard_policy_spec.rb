require "spec_helper"

module Decidim
  module Admin
    describe DashboardPolicy do
      subject { described_class.new(user, :dashboard) }

      context "show?" do
        context "being a regular user" do
          let(:user) { create(:user) }

          it { is_expected.to forbid_action(:show) }
        end

        context "being an admin" do
          let(:user) { create(:user, :admin) }

          it { is_expected.to permit_action(:show) }
        end
      end
    end
  end
end
