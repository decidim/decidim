# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/access_mode_restricted_participatory_spaces"

describe "Access Mode Restricted Participatory Processes" do
  let!(:participatory_space) { create(:participatory_process, :published, organization:) }
  let!(:restricted_participatory_space) { create(:participatory_process, :published, :restricted, organization:) }
  let!(:member) { create(:member, user: other_user, participatory_space: restricted_participatory_space) }
  let!(:member2) { create(:member, user: other_user2, participatory_space: restricted_participatory_space) }
  let!(:other_user) { create(:user, :confirmed, organization:) }
  let!(:other_user2) { create(:user, :confirmed, organization:) }

  let(:participatory_space_index_path) { decidim_participatory_processes.participatory_processes_path(locale: I18n.locale) }
  let(:restricted_participatory_space_path) { decidim_participatory_processes.participatory_process_path(restricted_participatory_space, locale: I18n.locale) }
  let(:restricted_participatory_space_attachment_path) { decidim_admin_participatory_processes.participatory_process_attachments_path(restricted_participatory_space, locale: I18n.locale) }
  let(:css_class_selector) { "#processes-grid" }
  let(:participatory_space_type) { :participatory_process }

  it_behaves_like "access mode restricted participatory spaces"
  it_behaves_like "access mode restricted participatory spaces comments"
end
