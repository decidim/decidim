# frozen_string_literal: true

require "spec_helper"

describe "Autocomplete multiselect", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:path) { URI.parse(decidim_admin.user_entities_organization_url).path }
  let(:url) { "http://#{organization.host}:#{Capybara.current_session.server.port}#{path}" }
  let(:selected) { '""' }

  before do
    final_html = html_document
    Rails.application.routes.draw do
      mount Decidim::Core::Engine => "/"
      get "test_multiselect", to: ->(_) { [200, {}, [final_html]] }
    end
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  after do
    expect_no_js_errors

    Rails.application.reload_routes!
  end

  context "when view has div that defines autocomplete multiselect" do
    let(:autocomplete_multifield_select) do
      %(
        <div data-autocomplete='
          {
            "name":"foo[user_id]",
            "mode": "multi",
            "options":[],
            "placeholder":"Select user",
            "searchURL":"#{url}",
            "selected":#{selected}
          }'
          data-autocomplete-for="user_id" data-plugin="autocomplete">
        </div>
      )
    end

    let(:html_head) { "" }
    let(:html_document) do
      head_extra = html_head
      body_extra = autocomplete_multifield_select
      template.instance_eval do
        <<~HTML.strip
          <!doctype html>
          <html lang="en">
          <head>
            <title>Autocomplete multiselect Test</title>
            #{stylesheet_pack_tag "decidim_admin"}
            #{javascript_pack_tag "decidim_admin"}
            #{head_extra}
          </head>
          <body>
            <h1>Hello world</h1>
            <label for="trustees_participatory_space_user_id">
            User
            <span title="Required field" data-tooltip="true" data-disable-hover="false" data-keep-on-hover="true" class="label-required">
            <span aria-hidden="true">*</span><span class="show-for-sr">Required field</span></span></label>
            #{body_extra}
            <div class="foo"></div>
          </body>
          </html>
        HTML
      end
    end
    let(:template_class) do
      Class.new(ActionView::Base) do
        # empty class
      end
    end
    let(:template) { template_class.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }

    before do
      visit "/test_multiselect"
    end

    describe "render autocomplete wrapper with text input" do
      it "shows multiselect" do
        within ".autoComplete_wrapper" do
          expect(page).to have_selector("input[type='text']", wait: 2)
        end
      end
    end

    context "when there is participants" do
      let!(:participant) { create(:user, :confirmed, organization: organization, name: "Andrea Kuhlman") }
      let!(:participant2) { create(:user, :confirmed, organization: organization, name: "Jenae Walsh") }
      let!(:participant3) { create(:user, :confirmed, organization: organization, name: "John Connor") }

      describe "select one participant" do
        it "shows selected participant and creates hidden input" do
          find("input[type='text']").fill_in with: participant.name.slice(0..2)
          find(".autoComplete_wrapper ul#autoComplete_list_1 li", match: :first, wait: 2).click
          expect(page).to have_content(participant.name)
          hidden_input = find("input[type='hidden']", visible: false)
          expect(hidden_input.value).to eq(participant.id.to_s)
          text_input = find("input[type='text']")
          expect(text_input.value).to eq("")
        end
      end

      describe "remove selected item" do
        it "selects and removes item" do
          autocomplete_select participant.name, from: :user_id
          expect(page).to have_content(participant.name)
          expect(page).to have_selector(%(input[value="#{participant.id}"]), visible: :hidden)
          find(".clear-multi-selection").click
          expect(page).not_to have_content(participant.name)
          expect(page).not_to have_selector(%(input[value="#{participant.id}"]), visible: :hidden)
        end
      end

      describe "select multiple participants" do
        it "shows selected participants and creates hidden inputs" do
          autocomplete_select participant.name, from: :user_id
          autocomplete_select participant2.name, from: :user_id
          expect(page).to have_content(participant.name)
          expect(page).to have_content(participant2.name)
          expect(page).not_to have_content(participant3.name)
          expect(page).to have_selector(%(input[value="#{participant.id}"]), visible: :hidden)
          expect(page).to have_selector(%(input[value="#{participant2.id}"]), visible: :hidden)
          expect(page).not_to have_selector(%(input[value="#{participant3.id}"]), visible: :hidden)
        end
      end

      describe "preselected values" do
        let(:selected) { %([{"value": "#{participant2.id}", "label": "#{participant2.name}"}, {"value": "#{participant3.id}", "label": "#{participant3.name}"}]) }

        it "shows preselected value" do
          expect(page).not_to have_content(participant.name)
          expect(page).to have_content(participant2.name)
          expect(page).to have_content(participant3.name)
          expect(page).not_to have_selector(%(input[value="#{participant.id}"]), visible: :hidden)
          expect(page).to have_selector(%(input[value="#{participant2.id}"]), visible: :hidden)
          expect(page).to have_selector(%(input[value="#{participant3.id}"]), visible: :hidden)
        end
      end
    end
  end
end
