# frozen_string_literal: true

shared_context "when administrating an assembly" do
  let(:organization) { create(:organization) }

  let!(:assembly) { create(:assembly, organization:) }
end
