# frozen_string_literal: true

require "spec_helper"

describe "Admin manages comments", type: :system do
  let!(:reportables) do
    create_list(:comment, 3, commentable:)
  end

  let(:participatory_space_path) do
    decidim_admin_initiatives.edit_initiative_path(commentable)
  end

  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let(:commentable) { create(:initiative, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_initiatives.initiatives_path
  end

  it_behaves_like "sorted moderations" do
    let!(:reportables) { create_list(:comment, 17, commentable:) }
    let!(:moderations) do
      reportables.first(reportables.length - 1).map do |reportable|
        moderation = create(:moderation, reportable:, participatory_space: commentable, report_count: 1)
        create(:report, moderation:)
        moderation
      end
    end
  end

  it_behaves_like "manage moderations" do
    let!(:moderations) do
      reportables.first(reportables.length - 1).map do |reportable|
        moderation = create(:moderation, reportable:, participatory_space: commentable, report_count: 1)
        create(:report, moderation:)
        moderation
      end
    end

    let!(:hidden_moderations) do
      reportables.last(1).map do |reportable|
        moderation = create(:moderation, reportable:, participatory_space: commentable, report_count: 3, hidden_at: Time.current)
        create_list(:report, 3, moderation:, reason: :spam)
        moderation
      end
    end
  end
end
