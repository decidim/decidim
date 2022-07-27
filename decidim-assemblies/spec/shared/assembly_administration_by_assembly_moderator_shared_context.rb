# frozen_string_literal: true

shared_context "when assembly moderator administrating an assembly" do
  let(:assembly) { create :assembly }
  let!(:user) { create(:assembly_moderator, :confirmed, organization:, assembly:) }

  include_context "when administrating an assembly"
end
