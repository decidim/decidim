# frozen_string_literal: true

shared_examples "manage question categories examples" do
  let(:participatory_space) { question }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_consultations.edit_question_path(question)
    click_link "Categories"
  end

  it_behaves_like "manage categories examples"
end
