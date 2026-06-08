# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/access_mode_transparent_participatory_spaces"

describe "Access Mode Transparent Assemblies" do
  let!(:organization) { create(:organization) }
  let!(:participatory_space) { create(:assembly, :published, organization:) }
  let!(:transparent_participatory_space) { create(:assembly, :published, :transparent, organization:) }

  let(:participatory_space_index_path) { decidim_assemblies.assemblies_path }
  let(:transparent_participatory_space_path) { decidim_assemblies.assembly_path(transparent_participatory_space) }
  let(:transparent_participatory_space_attachment_path) { decidim_admin_assemblies.assembly_attachments_path(transparent_participatory_space) }
  let(:css_class_selector) { "#assemblies-grid" }

  it_behaves_like "access mode transparent participatory spaces"
  it_behaves_like "access mode transparent participatory spaces comments"

  context "when accessing transparent assembly with elevated space roles" do
    before do
      switch_to_host(organization.host)
    end

    context "when user is a space admin" do
      let!(:space_admin) { create(:assembly_admin, :confirmed, assembly: transparent_participatory_space) }

      before do
        login_as space_admin, scope: :user
        visit transparent_participatory_space_path
      end

      it "can access the transparent assembly" do
        expect(page).to have_content(translated(transparent_participatory_space.title))
      end
    end

    context "when user is a space collaborator" do
      let!(:space_collaborator) { create(:assembly_collaborator, :confirmed, assembly: transparent_participatory_space) }

      before do
        login_as space_collaborator, scope: :user
        visit transparent_participatory_space_path
      end

      it "can access the transparent assembly" do
        expect(page).to have_content(translated(transparent_participatory_space.title))
      end
    end

    context "when user is a space moderator" do
      let!(:space_moderator) { create(:assembly_moderator, :confirmed, assembly: transparent_participatory_space) }

      before do
        login_as space_moderator, scope: :user
        visit transparent_participatory_space_path
      end

      it "can access the transparent assembly" do
        expect(page).to have_content(translated(transparent_participatory_space.title))
      end
    end

    context "when user is a space evaluator" do
      let!(:space_evaluator) { create(:assembly_evaluator, :confirmed, assembly: transparent_participatory_space) }

      before do
        login_as space_evaluator, scope: :user
        visit transparent_participatory_space_path
      end

      it "can access the transparent assembly" do
        expect(page).to have_content(translated(transparent_participatory_space.title))
      end
    end

    context "when user is a member" do
      let!(:member_user) { create(:user, :confirmed, organization:) }
      let!(:member) { create(:assembly_member, user: member_user, participatory_space: transparent_participatory_space) }

      before do
        login_as member_user, scope: :user
        visit transparent_participatory_space_path
      end

      it "can access the transparent assembly" do
        expect(page).to have_content(translated(transparent_participatory_space.title))
      end
    end
  end
end
