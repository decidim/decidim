# frozen_string_literal: true

RSpec.shared_context "participatory process administration by admin" do
  let!(:user) do
    create(:user, :admin, :confirmed, organization: organization)
  end

  include_context "participatory process administration"
end
