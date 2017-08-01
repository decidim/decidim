# frozen_string_literal: true

RSpec.shared_context "participatory process administration by process admin" do
  let!(:user) do
    create(:user,
           :process_admin,
           :confirmed,
           organization: organization,
           participatory_process: participatory_process)
  end

  include_context "participatory process administration"
end
