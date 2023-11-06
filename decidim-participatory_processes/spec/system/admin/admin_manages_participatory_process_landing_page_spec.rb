# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process landing page", type: :system do
  include_context "when admin administrating a participatory process with hero content block registered"
  let!(:resource) { participatory_process }
  let(:scope_name) { :participatory_process_homepage }
  let(:edit_landing_page_path) { decidim_admin_participatory_processes.edit_participatory_process_landing_page_path(resource) }

  def edit_content_block_path(resource, content_block)
    decidim_admin_participatory_processes.edit_participatory_process_landing_page_content_block_path(resource, content_block)
  end

  it_behaves_like "manage landing page examples"
end
