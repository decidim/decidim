# frozen_string_literal: true

require "spec_helper"

describe "User is being blocked by admin", type: :system do
  subject { Decidim::Admin::BlockUser.new(form) }

  let(:organization) { create(:organization) }
  let(:user_to_block) { create(:user, :confirmed, organization:) }
  let(:current_user) { create(:user, :admin, organization:) }

  let(:form) do
    double(
      user: user_to_block,
      current_user:,
      justification: "justification for blocking the user",
      valid?: true,
      hide?: true
    )
  end

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok, user_to_block)
  end

  it_behaves_like "fires an ActiveSupport::Notification event", "decidim.admin.block_user:after" do
    let(:command) { subject }
  end
end
