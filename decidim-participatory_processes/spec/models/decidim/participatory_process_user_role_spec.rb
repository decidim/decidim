# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatoryProcessUserRole do
    subject { participatory_process_user_role }

    let(:participatory_process_user_role) { build(:participatory_process_user_role, role:) }
    let(:role) { "admin" }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }
  end
end
