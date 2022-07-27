# frozen_string_literal: true

shared_context "when admin administrating a participatory process" do
  let!(:user) do
    create(:user, :admin, :confirmed, organization:)
  end

  include_context "when administrating a participatory process"
end
