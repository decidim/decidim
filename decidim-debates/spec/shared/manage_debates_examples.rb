# frozen_string_literal: true

RSpec.shared_examples "manage debates" do
  include_context "with taxonomy filters context"
  let(:participatory_space_manifests) { [participatory_process.manifest.name] }
  let(:taxonomies) { [taxonomy] }
  let!(:debate) { create(:debate, taxonomies:, component: current_component) }
  let(:attributes) { attributes_for(:debate, :closed, component: current_component) }

  before do
    current_component.update!(settings: { taxonomy_filters: [taxonomy_filter.id] })
    visit_component_admin
  end

  describe "listing" do
    context "with hidden debates" do
      let!(:my_other_debate) { create(:debate, taxonomies:, component: current_component) }

      before do
        my_other_debate.update!(title: { en: "Debate <strong>title</strong>" })
        create(:moderation, :hidden, reportable: my_other_debate)
      end

      it "does not list the hidden debates" do
        visit current_path
        expect(page).to have_no_content(translated(my_other_debate.title))
      end
    end

    context "with enriched content" do
      before do
        debate.update!(title: { en: "Debate <strong>title</strong>" })
        visit current_path
      end

      it "displays the correct title" do
        expect(page.html).to include("Debate &lt;strong&gt;title&lt;/strong&gt;")
      end
    end
  end

  describe "admin form" do
    before { click_on "New debate" }

    it_behaves_like "having a rich text editor", "new_debate", "full"
  end

  describe "updating a debate" do
    it "updates a debate", versioning: true do
      within "tr", text: translated(debate.title) do
        find("button[data-component='dropdown']").click
        click_on "Edit"
      end

      within ".edit_debate" do
        fill_in_i18n(:debate_title, "#debate-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n_editor(:debate_description, "#debate-description-tabs", **attributes[:description].except("machine_translations"))
        fill_in_i18n_editor(:debate_instructions, "#debate-instructions-tabs", **attributes[:instructions].except("machine_translations"))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout "Debate successfully updated"

      within "table" do
        expect(page).to have_content(translated(attributes[:title]))
      end

      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{translated(attributes[:title])} debate on the")
    end

    context "when the debate has an author" do
      let!(:debate) { create(:debate, :participant_author, component: current_component) }

      it "cannot edit the debate" do
        within "tr", text: translated(debate.title) do
          find("button[data-component='dropdown']").click
          expect(page).to have_no_content("Edit")
        end
      end
    end

    context "when debate has existing comments" do
      let!(:debate) { create(:debate, component: current_component, comments_layout: "two_columns") }
      let!(:comment) { create(:comment, commentable: debate, body: { "en" => "This is a test comment" }) }

      it "prevents admin from updating debate layout once comments have been posted" do
        within "tr", text: translated(debate.title) do
          find("button[data-component='dropdown']").click
          click_on "Edit"
        end

        within ".edit_debate" do
          choose "Single column"
          find("*[type=submit]").click
        end

        expect(page).to have_content("You cannot change the comment layout once comments have been posted")

        debate.reload
        expect(debate.comments_layout).to eq("two_columns")
      end
    end
  end

  describe "previewing debates" do
    it "links the debate correctly" do
      within "tr", text: translated(debate.title) do
        find("button[data-component='dropdown']").click
        link = find("a", text: "Preview")
        expect(link[:href]).to include(resource_locator(debate).path)
      end
    end

    it "shows a preview of the debate" do
      visit resource_locator(debate).path
      expect(page).to have_content(translated(debate.title))
    end
  end

  it "creates a new finite debate", versioning: true do
    click_on "New debate"

    within ".new_debate" do
      fill_in_i18n(:debate_title, "#debate-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:debate_description, "#debate-description-tabs", **attributes[:description].except("machine_translations"))
      fill_in_i18n_editor(:debate_instructions, "#debate-instructions-tabs", **attributes[:instructions].except("machine_translations"))

      choose "Finite"
    end

    fill_in_datepicker :debate_start_time_date, with: Time.current.change(day: 12).strftime("%d/%m/%Y")
    fill_in_timepicker :debate_start_time_time, with: "10:50"
    fill_in_datepicker :debate_end_time_date, with: Time.current.change(day: 12).strftime("%d/%m/%Y")
    fill_in_timepicker :debate_end_time_time, with: "12:50"

    within ".new_debate" do
      select(decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}")

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout "Debate successfully created"

    within "table" do
      expect(page).to have_content(translated(attributes[:title]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("created the #{translated(attributes[:title])} debate on the")

    visit decidim.last_activities_path
    expect(page).to have_content("New debate: #{decidim_sanitize_translated(attributes[:title])}")

    within "#filters" do
      find("a", class: "filter", text: "Debate", match: :first).click
    end
    expect(page).to have_content("New debate: #{decidim_sanitize_translated(attributes[:title])}")
  end

  it "creates a new open debate" do
    click_on "New debate"

    within ".new_debate" do
      fill_in_i18n(:debate_title, "#debate-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:debate_description, "#debate-description-tabs", **attributes[:description].except("machine_translations"))
      fill_in_i18n_editor(:debate_instructions, "#debate-instructions-tabs", **attributes[:instructions].except("machine_translations"))

      choose "Open"
    end

    expect(page).to have_no_selector "#debate_start_time"
    expect(page).to have_no_selector "#debate_end_time"

    within ".new_debate" do
      select(decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}")

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout "Debate successfully created"

    within "table" do
      expect(page).to have_content(translated(attributes[:title]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("created the #{translated(attributes[:title])} debate on the")
  end

  it "creates a new debate with two columns layout" do
    click_on "New debate"

    within ".new_debate" do
      fill_in_i18n(:debate_title, "#debate-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:debate_description, "#debate-description-tabs", **attributes[:description].except("machine_translations"))
      fill_in_i18n_editor(:debate_instructions, "#debate-instructions-tabs", **attributes[:instructions].except("machine_translations"))

      choose "Open"
      choose "Two columns"
    end

    within ".new_debate" do
      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout "Debate successfully created"

    within "table" do
      expect(page).to have_content(translated(attributes[:title]))
    end
  end

  describe "Attachments in a debate" do
    let(:image_filename) { "city2.jpeg" }
    let(:image_path) { Decidim::Dev.asset(image_filename) }
    let(:document_filename) { "Exampledocument.pdf" }
    let(:document_path) { Decidim::Dev.asset(document_filename) }
    let(:invalid_document) { Decidim::Dev.asset("invalid_extension.log") }

    before do
      component_settings = current_component["settings"]["global"].merge!(attachments_allowed: true)
      current_component.update!(settings: component_settings)
    end

    context "when creating a debate with attachments" do
      before do
        click_on "New debate"
      end

      it "creates a new debate with attachments" do
        within ".new_debate" do
          fill_in_i18n(:debate_title, "#debate-title-tabs", **attributes[:title].except("machine_translations"))
          fill_in_i18n_editor(:debate_description, "#debate-description-tabs", **attributes[:description].except("machine_translations"))
          fill_in_i18n_editor(:debate_instructions, "#debate-instructions-tabs", **attributes[:instructions].except("machine_translations"))

          choose "Open"
        end

        dynamically_attach_file(:debate_documents, image_path)
        dynamically_attach_file(:debate_documents, document_path)

        within ".new_debate" do
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout "Debate successfully created"

        within "tr[data-id=\"#{Decidim::Debates::Debate.last.id}\"]" do
          find("button[data-component='dropdown']").click
          click_on "Edit"
        end

        expect(page).to have_css("img[src*='#{image_filename}']")
        expect(page).to have_content(document_filename)
      end

      it "shows validation error when format is not accepted" do
        dynamically_attach_file(:debate_documents, invalid_document, keep_modal_open: true) do
          expect(page).to have_content("Accepted formats: #{Decidim::OrganizationSettings.for(organization).upload_allowed_file_extensions.join(", ")}")
        end
        expect(page).to have_content("Validation error!")
      end
    end

    context "when editing a debate with attachments" do
      before do
        within "tr[data-id=\"#{debate.id}\"]" do
          find("button[data-component='dropdown']").click
          click_on "Edit"
        end
      end

      it "updates the debate with new attachments", :slow do
        within ".edit_debate" do
          fill_in_i18n(:debate_title, "#debate-title-tabs", **attributes[:title].except("machine_translations"))
          fill_in_i18n_editor(:debate_description, "#debate-description-tabs", **attributes[:description].except("machine_translations"))
          fill_in_i18n_editor(:debate_instructions, "#debate-instructions-tabs", **attributes[:instructions].except("machine_translations"))
        end

        dynamically_attach_file(:debate_documents, image_path)
        dynamically_attach_file(:debate_documents, document_path)

        within ".edit_debate" do
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout "Debate successfully updated"

        within "tr[data-id=\"#{debate.id}\"]" do
          find("button[data-component='dropdown']").click
          click_on "Edit"
        end

        expect(page).to have_css("img[src*='#{image_filename}']")
        expect(page).to have_content(document_filename)
      end
    end

    context "when attachments are not allowed" do
      before do
        component_settings = current_component["settings"]["global"].merge!(attachments_allowed: false)
        current_component.update!(settings: component_settings)
        click_on "New debate"
      end

      it "does not show the attachments form", :slow do
        expect(page).to have_no_css("#debate_documents_button")
      end
    end
  end

  describe "closing a debate", versioning: true do
    it "closes a debate" do
      within "tr", text: translated(debate.title) do
        find("button[data-component='dropdown']").click
        click_on "Close"
      end

      within ".edit_close_debate" do
        fill_in_i18n_editor(:debate_conclusions, "#debate-conclusions-tabs", **attributes[:conclusions].except("machine_translations"))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout "Debate successfully closed"

      within "table" do
        within "tr", text: translated(debate.title) do
          find("button[data-component='dropdown']").click
          click_on "Close"
        end
      end

      expect(page).to have_content(strip_tags(translated(attributes[:conclusions])).strip)

      visit decidim_admin.root_path
      expect(page).to have_content("performed some action on #{translated(debate.title)} in")
    end

    context "when the debate has an author" do
      let!(:debate) { create(:debate, :participant_author, component: current_component) }

      it "cannot close the debate" do
        within "tr", text: translated(debate.title) do
          find("button[data-component='dropdown']").click
          expect(page).to have_no_content("Close")
        end
      end
    end
  end
end
