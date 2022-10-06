# frozen_string_literal: true

shared_context "when conference moderator administrating an conference" do
  let(:conference) { create :conference }
  let!(:user) { create(:conference_moderator, :confirmed, organization:, conference:) }

  include_context "when administrating a conference"
end
