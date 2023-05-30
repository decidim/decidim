# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe ParticipatorySpace::DestroyAdmin, versioning: true do
    subject { described_class.new(role, current_user) }

    context "when the role is a participatory space admin" do
      let(:my_process) { create(:participatory_process) }
      let(:role) { create(:participatory_process_user_role, user:, participatory_process: my_process, role: :admin) }

      include_examples "destroys participatory space role"
    end
  end
end
