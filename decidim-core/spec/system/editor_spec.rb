# frozen_string_literal: true

require "spec_helper"

describe "Editor", type: :system do
  let!(:organization) { create(:organization) }
  let(:content) { "" }
  let(:toolbar) { "full" }

  before do
    spec = self
    request_context = {
      "decidim.current_organization" => organization
    }
    editor_config = {
      toolbar: toolbar,
      content: content
    }

    # Map a special route for rendering the editor
    Rails.application.routes.disable_clear_and_finalize = true
    Rails.application.routes.draw do
      get "test_editor", to: (
        lambda do |env|
          controller = Decidim::ApplicationController.new

          request = ActionDispatch::Request.new(env.merge(request_context))
          request.routes = controller._routes
          controller.set_request! request
          controller.set_response! Decidim::ApplicationController.make_response!(request)

          view = controller.view_context
          spec.allow(controller).to spec.receive(:view_context).and_return(view)
          spec.allow(view).to spec.receive(:request).and_return(request)
          spec.allow(view).to spec.receive(:url_for).and_return("/")

          [
            200,
            {},
            [
              controller.render_to_string(
                inline: %(
                  <div id="editor">
                    #{view.hidden_field_tag(:content, editor_config[:content])}
                    <div class="editor-container" data-toolbar="#{editor_config[:toolbar]}"></div>
                  </div>
                ),
                layout: "decidim/application"
              )
            ]
          ]
        end
      )
    end
    Rails.application.routes.disable_clear_and_finalize = false

    visit "/test_editor"
  end

  after do
    # Reset the routes back to original
    Rails.application.reload_routes!
  end

  it "renders the editor" do
    expect(page).to have_selector("#editor .ql-editor.ql-blank", text: "")
    expect(find("#editor .ql-editor")["innerHTML"]).to eq("<p><br></p>")
  end

  context "with list content" do
    let(:content) do
      # This is actually how the content is saved from quill.js to the Decidim
      # database.
      <<~HTML
        <p>Paragraph</p><ul>
        <li>List item 1</li>
        <li>List item 2</li>
        <li>List item 3</li></ul><p>Another paragraph</p>
      HTML
    end

    it "renders the correct content inside the editor" do
      expect(find("#editor .ql-editor")["innerHTML"]).to eq(content.gsub("\n", ""))
    end
  end
end
