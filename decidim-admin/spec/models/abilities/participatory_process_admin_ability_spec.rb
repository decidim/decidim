# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe Abilities::ParticipatoryProcessAdminAbility do
    subject { described_class.new(user, current_participatory_process: user_process) }

    let(:user) { build(:user) }
    let(:user_process) { create :participatory_process, organization: user.organization }

    context "when the user does not admin any process" do
      it { is_expected.not_to be_able_to(:read, :admin_dashboard) }
    end

    context "when the user is an admin for some process", processing_uploads_for: Decidim::AttachmentUploader do
      let(:unmanaged_process) { create :participatory_process, organization: user.organization }
      let(:user_process_step) { create :participatory_process_step, participatory_process: user_process }
      let(:unmanaged_process_step) { create :participatory_process_step, participatory_process: unmanaged_process }
      let(:user_process_attachment) { create :attachment, attached_to: user_process }
      let(:unmanaged_process_attachment) { create :attachment, attached_to: unmanaged_process }
      let(:feature) { create(:feature, participatory_space: user_process) }
      let(:dummy_resource) { create(:dummy_resource, feature: feature) }
      let(:user_process_moderation) { create(:moderation, reportable: dummy_resource) }
      let(:unmanaged_process_moderation) { create(:moderation) }

      before do
        create :participatory_process_user_role, user: user, participatory_process: user_process, role: :admin
      end

      it { is_expected.to be_able_to(:read, :admin_dashboard) }

      it { is_expected.to be_able_to(:read, user_process) }
      it { is_expected.to be_able_to(:update, user_process) }
      it { is_expected.not_to be_able_to(:destroy, user_process) }
      it { is_expected.not_to be_able_to(:create, Decidim::ParticipatoryProcess) }
      it { is_expected.not_to be_able_to(:manage, unmanaged_process) }

      it { is_expected.not_to be_able_to(:manage, :admin_users) }

      it { is_expected.to be_able_to(:manage, user_process_step) }
      it { is_expected.not_to be_able_to(:manage, unmanaged_process_step) }

      it { is_expected.to be_able_to(:manage, user_process_attachment) }
      it { is_expected.not_to be_able_to(:manage, unmanaged_process_attachment) }

      it { is_expected.to be_able_to(:manage, user_process_moderation) }
      it { is_expected.not_to be_able_to(:manage, unmanaged_process_moderation) }
    end
  end
end
