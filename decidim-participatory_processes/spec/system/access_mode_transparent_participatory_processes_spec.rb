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

  context "when accessing transparent process and user has space roles assigned" do
    context "when user is a space admin" do
      it_behaves_like "access mode transparent participatory spaces" do
        let!(:admin) { create(:process_admin, :confirmed, participatory_process: transparent_participatory_space) }
        let!(:user) { admin }
      end
    end

    context "when user is a space collaborator" do
      it_behaves_like "access mode transparent participatory spaces" do
        let!(:admin) { create(:process_collaborator, :confirmed, participatory_process: transparent_participatory_space) }
        let!(:user) { admin }
      end
    end

    context "when user is a space moderator" do
      it_behaves_like "access mode transparent participatory spaces", with_attachments: false do
        let!(:admin) { create(:process_moderator, :confirmed, participatory_process: transparent_participatory_space) }
        let!(:user) { admin }
      end
    end

    context "when user is a space evaluator" do
      it_behaves_like "access mode transparent participatory spaces", with_attachments: false do
        let!(:admin) { create(:process_evaluator, :confirmed, participatory_process: transparent_participatory_space) }
        let!(:user) { admin }
      end
    end

    context "when user is a member" do
      it_behaves_like "access mode transparent participatory spaces" do
        let!(:user) { create(:user, :confirmed, organization:) }
        let!(:member) { create(:member, user:, participatory_space: transparent_participatory_space) }
      end
    end
  end
end
