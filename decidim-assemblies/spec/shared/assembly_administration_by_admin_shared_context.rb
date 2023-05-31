# frozen_string_literal: true

shared_context "when admin administrating an assembly" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }

  include_context "when administrating an assembly"
end
