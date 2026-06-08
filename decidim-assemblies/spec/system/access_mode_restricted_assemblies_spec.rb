# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/access_mode_restricted_participatory_spaces"

describe "Access Mode Restricted Assemblies" do
  let!(:participatory_space) { create(:assembly, :published, organization:) }
  let!(:restricted_participatory_space) { create(:assembly, :published, organization:, access_mode: :restricted) }
  let!(:member) { create(:assembly_member, user: other_user, participatory_space: restricted_participatory_space) }
  let!(:member2) { create(:assembly_member, user: other_user2, participatory_space: restricted_participatory_space) }
  let!(:other_user) { create(:user, :confirmed, organization:) }
  let!(:other_user2) { create(:user, :confirmed, organization:) }

  let(:participatory_space_index_path) { decidim_assemblies.assemblies_path }
  let(:restricted_participatory_space_path) { decidim_assemblies.assembly_path(restricted_participatory_space) }
  let(:restricted_participatory_space_attachment_path) { decidim_admin_assemblies.assembly_attachments_path(restricted_participatory_space) }
  let(:css_class_selector) { "#assemblies-grid" }

  it_behaves_like "access mode restricted participatory spaces"
  it_behaves_like "access mode restricted participatory spaces comments"

  context "when accessing restricted assembly as elevated space roles" do
    context "when user is a space admin" do
      let!(:space_admin) { create(:assembly_admin, :confirmed, assembly: restricted_participatory_space) }

      it_behaves_like "access mode restricted participatory spaces"
    end

    context "when user is a space collaborator" do
      let!(:space_collaborator) { create(:assembly_collaborator, :confirmed, assembly: restricted_participatory_space) }

      it_behaves_like "access mode restricted participatory spaces"
    end

    context "when user is a space moderator" do
      let!(:space_moderator) { create(:assembly_moderator, :confirmed, assembly: restricted_participatory_space) }

      it_behaves_like "access mode restricted participatory spaces"
    end

    context "when user is a space evaluator" do
      let!(:space_evaluator) { create(:assembly_evaluator, :confirmed, assembly: restricted_participatory_space) }

      before do
        login_as space_evaluator, scope: :user
        visit restricted_participatory_space_path
      end

      it_behaves_like "access mode restricted participatory spaces"
    end
  end
end
