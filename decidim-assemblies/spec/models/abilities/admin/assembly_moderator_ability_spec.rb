# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Assemblies::Abilities::Admin::AssemblyModeratorAbility do
    subject { described_class.new(user, current_participatory_space: user_assembly) }

    let(:user) { build(:user) }
    let(:user_assembly) { create :assembly, organization: user.organization }

    context "when the user does not admin any assembly" do
      it { is_expected.not_to be_able_to(:read, :admin_dashboard) }
    end

    context "when the user is an admin for some assembly" do
      let(:unmanaged_assembly) { create :assembly, organization: user.organization }
      let(:component) { create(:component, participatory_space: user_assembly) }
      let(:unmanaged_component) { create(:component, participatory_space: unmanaged_assembly) }
      let(:dummy_resource) { create(:dummy_resource, component: component) }
      let(:user_assembly_moderation) { create(:moderation, reportable: dummy_resource) }
      let(:unmanaged_assembly_moderation) { create(:moderation) }

      let!(:user_role) { create :assembly_user_role, user: user, assembly: user_assembly, role: :moderator }

      it { is_expected.to be_able_to(:read, :admin_dashboard) }

      it { is_expected.to be_able_to(:read, user_assembly) }
      it { is_expected.to be_able_to(:index, user_assembly) }
      it { is_expected.not_to be_able_to(:preview, user_assembly) }
      it { is_expected.not_to be_able_to(:destroy, user_assembly) }
      it { is_expected.not_to be_able_to(:create, Decidim::Assembly) }
      it { is_expected.not_to be_able_to(:update, user_assembly) }
      it { is_expected.not_to be_able_to(:manage, unmanaged_assembly) }

      it { is_expected.to be_able_to(:manage, user_assembly_moderation) }
      it { is_expected.not_to be_able_to(:manage, unmanaged_assembly_moderation) }
      it { is_expected.to be_able_to(:hide, dummy_resource) }
      it { is_expected.to be_able_to(:unreport, dummy_resource) }
    end
  end
end
