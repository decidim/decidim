# frozen_string_literal: true

shared_context "when admin administrating a conference" do
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }

  include_context "when administrating a conference"
end
