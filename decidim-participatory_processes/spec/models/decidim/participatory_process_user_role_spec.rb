# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatoryProcessUserRole do
    subject { participatory_process_user_role }

    let(:participatory_process_user_role) { build(:participatory_process_user_role, role:) }
    let(:role) { "admin" }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    it "has an association of participatory_process" do
      expect(participatory_process_user_role.participatory_process).to be_a(Decidim::ParticipatoryProcess)
    end

    it "has the participatory_process_user_roles association as the inverse of the participatory process" do
      participatory_process_user_role.save!

      expect(participatory_process_user_role.participatory_process.participatory_process_user_roles)
        .to eq([participatory_process_user_role])
      expect(participatory_process_user_role.participatory_process.participatory_process_user_roles.first.participatory_process)
        .to be(participatory_process_user_role.participatory_process)
    end
  end
end
