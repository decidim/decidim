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

  it "enqueues a training job" do
    expect { subject.call }.to have_enqueued_job(Decidim::Ai::TrainUserDataJob).on_queue("spam_analysis").with(user_to_block)
  end
end
