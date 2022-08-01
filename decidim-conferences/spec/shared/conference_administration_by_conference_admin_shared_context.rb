# frozen_string_literal: true

shared_context "when conference admin administrating a conference" do
  let!(:user) do
    create(
      :conference_admin,
      :confirmed,
      organization:,
      conference:
    )
  end

  include_context "when administrating a conference"
end
