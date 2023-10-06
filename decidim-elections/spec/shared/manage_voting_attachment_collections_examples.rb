# frozen_string_literal: true

shared_examples "manage voting attachment collections examples" do
  let(:collection_for) { voting }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_votings.edit_voting_path(voting)
    within_admin_sidebar_menu do
      click_link "Folders"
    end
  end

  it_behaves_like "manage attachment collections examples"
end
