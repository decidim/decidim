# frozen_string_literal: true
require "spec_helper"

describe Decidim::Admin::Abilities::ParticipatoryProcessAdmin do
  let(:user) { build(:user) }
  let(:user_process) { create :participatory_process, organization: user.organization }

  subject { described_class.new(user, {}) }

  context "when the user does not admin any process" do
    it { is_expected.not_to be_able_to(:read, :admin_dashboard) }
  end

  context "when the user is an admin for some process" do
    let(:unmanaged_process) { create :participatory_process, organization: user.organization }
    let(:user_process_step) { create :participatory_process_step, participatory_process: user_process }
    let(:unmanaged_process_step) { create :participatory_process_step, participatory_process: unmanaged_process }
    let(:user_process_attachment) do
      Decidim::AttachmentUploader.enable_processing = true
      create :attachment, attached_to: user_process
    end
    let(:unmanaged_process_attachment) do
      Decidim::AttachmentUploader.enable_processing = true
      create :attachment, attached_to: unmanaged_process
    end

    before do
      create :participatory_process_user_role, user: user, participatory_process: user_process
    end

    it { is_expected.to be_able_to(:read, :admin_dashboard) }

    it { is_expected.to be_able_to(:read, user_process) }
    it { is_expected.to be_able_to(:update, user_process) }
    it { is_expected.not_to be_able_to(:destroy, user_process) }
    it { is_expected.not_to be_able_to(:create, Decidim::ParticipatoryProcess) }
    it { is_expected.not_to be_able_to(:manage, unmanaged_process) }

    it { is_expected.to be_able_to(:manage, user_process_step) }
    it { is_expected.not_to be_able_to(:manage, unmanaged_process_step) }

    it { is_expected.to be_able_to(:manage, user_process_attachment) }
    it { is_expected.not_to be_able_to(:manage, unmanaged_process_attachment) }
  end
end
