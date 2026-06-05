# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/access_mode_transparent_participatory_spaces"

describe "Access Mode Transparent Participatory Processes" do
  let!(:organization) { create(:organization) }
  let!(:participatory_space) { create(:participatory_process, :published, organization:) }
  let!(:transparent_participatory_space) { create(:participatory_process, :published, :transparent, organization:) }

  let(:participatory_space_index_path) { decidim_participatory_processes.participatory_processes_path(locale: I18n.locale) }
  let(:transparent_participatory_space_path) { decidim_participatory_processes.participatory_process_path(transparent_participatory_space, locale: I18n.locale) }
  let(:transparent_participatory_space_attachment_path) { decidim_admin_participatory_processes.participatory_process_attachments_path(transparent_participatory_space, locale: I18n.locale) }
  let(:css_class_selector) { "#processes-grid" }

  it_behaves_like "access mode transparent participatory spaces"
  it_behaves_like "access mode transparent participatory spaces comments"
end
