# frozen_string_literal: true

shared_context "when administrating a conference" do
  let(:organization) { create(:organization) }

  let!(:conference) { create(:conference, organization:) }
end
