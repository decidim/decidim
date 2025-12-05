# frozen_string_literal: true

require "spec_helper"
describe "Report Comment" do
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:participatory_space) { commentable }
  let(:participatory_process) { commentable }
  let!(:commentable) { create(:initiative, organization:) }
  let!(:reportable) { create(:comment, commentable:) }
  let(:reportable_path) { decidim_initiatives.initiative_path(commentable, locale: I18n.locale) }

  before do
    switch_to_host(organization.host)
  end

  include_examples "comments_reports"
end
