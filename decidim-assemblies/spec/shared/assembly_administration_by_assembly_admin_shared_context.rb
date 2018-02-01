# frozen_string_literal: true

shared_context "when assembly admin administrating an assembly" do
  let(:assembly) { create :assembly }
  let!(:user) { create(:assembly_admin, :confirmed, organization: organization, assembly: assembly) }

  include_context "when administrating an assembly"
end
