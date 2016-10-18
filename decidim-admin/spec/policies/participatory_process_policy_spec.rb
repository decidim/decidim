require "spec_helper"

module Decidim
  module Admin
    describe ParticipatoryProcessPolicy do
      let(:organization) { create :organization }
      let(:organization2) { create :organization }
      let(:process) { create(:participatory_process, organization: organization) }

      subject { described_class.new(user, process) }

      context "create?" do
        context "being a regular user" do
          let(:user) { create(:user) }

          it { is_expected.to forbid_action(:create) }
        end

        context "being an admin" do
          let(:user) { create(:user, :admin) }

          it { is_expected.to permit_action(:create) }
        end
      end

      context "new?" do
        context "being a regular user" do
          let(:user) { create(:user) }

          it { is_expected.to forbid_action(:new) }
        end

        context "being an admin" do
          let(:user) { create(:user, :admin) }

          it { is_expected.to permit_action(:new) }
        end
      end

      context "index?" do
        let(:processes) { [create(:participatory_process, organization: organization)] }

        subject { described_class.new(user, processes) }

        context "with an empty collection" do
          let(:user) { create(:user, :admin, organization: organization) }
          let(:processes) { [] }

          it { is_expected.to permit_action(:index) }
        end

        context "being a regular user" do
          let(:user) { create(:user) }

          it { is_expected.to forbid_action(:index) }
        end

        context "being an admin" do
          let(:user) { create(:user, :admin, organization: organization) }

          context "with the same organization" do
            it { is_expected.to permit_action(:index) }
          end

          context "with a different organization" do
            let(:user) { create(:user, :admin, organization: organization2) }

            it { is_expected.to forbid_action(:index) }
          end
        end
      end

      context "show?" do
        context "being a regular user" do
          let(:user) { create(:user) }

          it { is_expected.to forbid_action(:show) }
        end

        context "being an admin" do
          let(:user) { create(:user, :admin, organization: organization) }

          context "with the same organization" do
            it { is_expected.to permit_action(:show) }
          end

          context "with a different organization" do
            let(:user) { create(:user, :admin, organization: organization2) }

            it { is_expected.to forbid_action(:show) }
          end
        end
      end

      context "edit?" do
        context "being a regular user" do
          let(:user) { create(:user) }

          it { is_expected.to forbid_action(:edit) }
        end

        context "being an admin" do
          let(:user) { create(:user, :admin, organization: organization) }

          context "with the same organization" do
            it { is_expected.to permit_action(:edit) }
          end

          context "with a different organization" do
            let(:user) { create(:user, :admin, organization: organization2) }

            it { is_expected.to forbid_action(:edit) }
          end
        end
      end

      context "update?" do
        context "being a regular user" do
          let(:user) { create(:user) }

          it { is_expected.to forbid_action(:update) }
        end

        context "being an admin" do
          let(:user) { create(:user, :admin, organization: organization) }

          context "with the same organization" do
            it { is_expected.to permit_action(:update) }
          end

          context "with a different organization" do
            let(:user) { create(:user, :admin, organization: organization2) }

            it { is_expected.to forbid_action(:update) }
          end
        end
      end

      context "destroy?" do
        context "being a regular user" do
          let(:user) { create(:user) }

          it { is_expected.to forbid_action(:destroy) }
        end

        context "being an admin" do
          let(:user) { create(:user, :admin, organization: organization) }

          context "with the same organization" do
            it { is_expected.to permit_action(:destroy) }
          end

          context "with a different organization" do
            let(:user) { create(:user, :admin, organization: organization2) }

            it { is_expected.to forbid_action(:destroy) }
          end
        end
      end
    end
  end
end
