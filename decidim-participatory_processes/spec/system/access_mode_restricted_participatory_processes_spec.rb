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

  context "when accessing restricted process with elevated space roles" do
    let(:organization) { create(:organization) }

    before do
      switch_to_host(organization.host)
    end

    context "when user is a space admin" do
      let!(:space_admin) { create(:process_admin, :confirmed, participatory_process: restricted_participatory_space) }

      before do
        login_as space_admin, scope: :user
        visit restricted_participatory_space_path
      end

      it "can access the restricted process" do
        expect(page).to have_content(translated(restricted_participatory_space.title))
      end
    end

    context "when user is a space collaborator" do
      let!(:space_collaborator) { create(:process_collaborator, :confirmed, participatory_process: restricted_participatory_space) }

      before do
        login_as space_collaborator, scope: :user
        visit restricted_participatory_space_path
      end

      it "can access the restricted process" do
        expect(page).to have_content(translated(restricted_participatory_space.title))
      end
    end

    context "when user is a space moderator" do
      let!(:space_moderator) { create(:process_moderator, :confirmed, participatory_process: restricted_participatory_space) }

      before do
        login_as space_moderator, scope: :user
        visit restricted_participatory_space_path
      end

      it "can access the restricted process" do
        expect(page).to have_content(translated(restricted_participatory_space.title))
      end
    end

    context "when user is a space evaluator" do
      let!(:space_evaluator) { create(:process_evaluator, :confirmed, participatory_process: restricted_participatory_space) }

      before do
        login_as space_evaluator, scope: :user
        visit restricted_participatory_space_path
      end

      it "can access the restricted process" do
        expect(page).to have_content(translated(restricted_participatory_space.title))
      end
    end

    context "when user is a regular user without any role" do
      let!(:regular_user) { create(:user, :confirmed, organization:) }

      before do
        login_as regular_user, scope: :user
        visit restricted_participatory_space_path
      end

      it "cannot access the restricted process" do
        expect(page).to have_no_content(translated(restricted_participatory_space.title))
      end
    end
  end
end
