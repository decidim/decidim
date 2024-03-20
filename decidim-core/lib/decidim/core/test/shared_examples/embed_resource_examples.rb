# frozen_string_literal: true

require "decidim/admin/test/admin_participatory_space_access_examples"

shared_examples "rendering the embed page correctly" do
  before do
    visit widget_path
  end

  it "renders" do
    if resource.title.is_a?(Hash)
      expect(page).to have_i18n_content(resource.title)
    else
      expect(page).to have_content(resource.title)
    end

    expect(page).to have_content(organization.name)
  end
end

shared_examples "rendering the embed link in the resource page" do
  before do
    visit resource_locator(resource).path
  end

  it "has the embed link" do
    expect(page).to have_button("Embed")
  end
end

shared_examples "showing the unauthorized message in the widget_path" do
  it do
    visit widget_path
    expect(page).to have_content "You are not authorized to perform this action"
  end
end

shared_examples "not rendering the embed link in the resource page" do
  before do
    visit resource_locator(resource).path
  end

  it "does not have the embed link" do
    expect(page).to have_no_button("Embed")
  end
end

shared_examples_for "an embed resource" do |options|
  if options.is_a?(Hash) && options[:skip_space_checks]
    let(:organization) { resource.organization }

    before do
      switch_to_host(organization.host)
    end
  else
    include_context "with a component"
  end

  unless options.is_a?(Hash) && options[:skip_publication_checks]
    context "when the resource is not published" do
      before do
        resource.unpublish!
      end

      it_behaves_like "not rendering the embed link in the resource page"

      it_behaves_like "a 404 page" do
        let(:target_path) { widget_path }
      end
    end
  end

  it_behaves_like "rendering the embed link in the resource page" unless options.is_a?(Hash) && options[:skip_link_checks]

  context "when visiting the embed page for a resource" do
    before do
      visit widget_path
    end

    it_behaves_like "rendering the embed page correctly"

    unless options.is_a?(Hash) && options[:skip_space_checks]
      context "when the participatory_space is a process" do
        it "shows the process name" do
          expect(page).to have_i18n_content(participatory_process.title)
        end
      end

      context "when the participatory_space is an assembly" do
        let(:assembly) do
          create(:assembly, organization: organization)
        end
        let(:participatory_space) { assembly }

        it "shows the assembly name" do
          expect(page).to have_i18n_content(assembly.title)
        end
      end
    end
  end
end

shared_examples_for "a private embed resource" do
  let(:organization) { resource.organization }
  let!(:other_user) { create(:user, :confirmed, organization: organization) }
  let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: other_user, privatable_to: resource) }

  before do
    switch_to_host(organization.host)
  end

  context "when the resource is private" do
    before do
      resource.update!(private_space: true)
      resource.update!(is_transparent: false) if resource.respond_to?(:is_transparent)
    end

    context "and user is a visitor" do
      let(:user) { nil }

      it_behaves_like "not rendering the embed link in the resource page"

      it_behaves_like "a 404 page" do
        let(:target_path) { widget_path }
      end
    end

    context "and user is a registered user" do
      let(:user) { create(:user, :confirmed, organization: organization) }

      before do
        sign_in user, scope: :user
      end

      it_behaves_like "not rendering the embed link in the resource page"

      it_behaves_like "a 404 page" do
        let(:target_path) { widget_path }
      end
    end

    context "and user is a private user" do
      let(:user) { other_user }

      before do
        sign_in user, scope: :user
      end

      it_behaves_like "a 404 page" do
        let(:target_path) { widget_path }
      end
    end
  end
end

shared_examples_for "a transparent private embed resource" do
  let(:organization) { resource.organization }
  let!(:other_user) { create(:user, :confirmed, organization: organization) }
  let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: other_user, privatable_to: resource) }

  before do
    switch_to_host(organization.host)
  end

  context "when the resource is private" do
    before do
      resource.update!(private_space: true)
      resource.update!(is_transparent: true) if resource.respond_to?(:is_transparent)
    end

    context "and user is a visitor" do
      let(:user) { nil }

      it_behaves_like "rendering the embed page correctly"
    end

    context "and user is a registered user" do
      let(:user) { create(:user, :confirmed, organization: organization) }

      before do
        sign_in user, scope: :user
      end

      it_behaves_like "rendering the embed page correctly"
    end

    context "and user is a private user" do
      let(:user) { other_user }

      before do
        sign_in user, scope: :user
      end

      it_behaves_like "rendering the embed page correctly"
    end
  end
end

shared_examples_for "a moderated embed resource" do
  include_context "with a component"

  context "when the resource is moderated" do
    let!(:moderation) { create(:moderation, reportable: resource, hidden_at: 2.days.ago) }

    it_behaves_like "a 404 page" do
      let(:target_path) { widget_path }
    end
  end
end

shared_examples_for "a withdrawn embed resource" do
  include_context "with a component"

  context "when the resource is withdrawn" do
    before do
      resource.update!(state: "withdrawn")
    end

    it_behaves_like "not rendering the embed link in the resource page"

    it_behaves_like "a 404 page" do
      let(:target_path) { widget_path }
    end
  end
end
