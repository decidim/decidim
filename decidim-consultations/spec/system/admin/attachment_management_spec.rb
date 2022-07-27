# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/manage_attachments_examples"

describe "question attachments", type: :system do
  include_context "when administrating a consultation"
  let(:question) { create(:question, consultation:) }

  let(:attached_to) { question }
  let(:attachment_collection) { create(:attachment_collection, collection_for: question) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_consultations.edit_question_path(question)
    click_link "Attachments"
  end

  it_behaves_like "manage attachments examples"
end
