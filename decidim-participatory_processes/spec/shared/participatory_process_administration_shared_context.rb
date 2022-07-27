# frozen_string_literal: true

shared_context "when administrating a participatory process" do
  let(:organization) { create(:organization) }

  let!(:participatory_process) { create(:participatory_process, organization:) }
end
