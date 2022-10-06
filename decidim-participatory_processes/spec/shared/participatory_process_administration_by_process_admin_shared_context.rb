# frozen_string_literal: true

shared_context "when process admin administrating a participatory process" do
  let!(:user) do
    create(
      :process_admin,
      :confirmed,
      organization:,
      participatory_process:
    )
  end

  include_context "when administrating a participatory process"
end
