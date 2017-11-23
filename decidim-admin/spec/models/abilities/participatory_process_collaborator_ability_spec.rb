# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe Abilities::ParticipatoryProcessCollaboratorAbility do
    subject { described_class.new(user, current_participatory_process: user_process) }

    let(:user) { build(:user) }
    let(:user_process) { create :participatory_process, organization: user.organization }
    let(:unmanaged_process) { create :participatory_process, organization: user.organization }

    before do
      create :participatory_process_user_role, user: user, participatory_process: user_process, role: :collaborator
    end

    it { is_expected.to be_able_to(:preview, user_process) }
    it { is_expected.not_to be_able_to(:preview, unmanaged_process) }
  end
end
