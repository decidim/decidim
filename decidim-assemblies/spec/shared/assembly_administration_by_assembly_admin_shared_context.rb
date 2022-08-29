# frozen_string_literal: true

shared_context "when assembly admin administrating an assembly" do
  let!(:user) do
    create(
      :assembly_admin,
      :confirmed,
      organization:,
      assembly:
    )
  end

  include_context "when administrating an assembly"
end
