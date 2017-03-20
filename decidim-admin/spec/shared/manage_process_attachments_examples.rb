# -*- coding: utf-8 -*-
# frozen_string_literal: true
require "decidim/admin/test/manage_attachments_examples"

RSpec.shared_examples "manage process attachments examples" do
  let(:attached_to) { participatory_process }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.edit_participatory_process_path(participatory_process)
    click_link "Attachments"
  end

  it_behaves_like "manage attachments examples"
end
