# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

require "decidim/core/test/shared_examples/form_builder_examples"

module Decidim
  describe FormBuilder do
    let(:helper) { Class.new(ActionView::Base).new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }
    let(:available_locales) { %w(ca en de-CH) }
    let(:uploader) { Decidim::ApplicationUploader }
    let(:organization) { create(:organization) }

    let(:resource) do
      class DummyClass
        cattr_accessor :current_organization

        def self.model_name
          ActiveModel::Name.new(self, nil, "dummy")
        end

        def self.attached_config
          attached_config = OpenStruct.new
          attached_config.uploader = Decidim::ImageUploader
          {
            image: attached_config
          }
        end

        extend ActiveModel::Translation
        include ActiveModel::Model
        include Decidim::AttributeObject::Model
        include TranslatableAttributes
        include Decidim::HasUploadValidations

        attribute :slug, String
        attribute :proposal_title, String
        attribute :category_id, Integer
        attribute :number, Integer
        attribute :max_number, Integer
        attribute :min_number, Integer
        attribute :conditional_presence, String
        attribute :image
        attribute :born_at, Date
        attribute :start_time, DateTime
        attribute :scopes, [::Decidim::Scope]

        translatable_attribute :name, String
        translatable_attribute :short_description, String

        validates :slug, presence: true
        validates :proposal_title, proposal_length: {
          minimum: 15,
          maximum: ->(_record) { 50 }
        }
        validates :number, length: { minimum: 10, maximum: 30 }
        validates :max_number, length: { maximum: 50 }
        validates :min_number, length: { minimum: 10 }
        validates :conditional_presence, presence: true, if: :validate_presence
        validates :born_at, presence: true
        validates :start_time, presence: true

        def validate_presence
          false
        end

        def organization
          current_organization
        end
      end

      klass = DummyClass.new
      klass.current_organization = organization
      klass
    end

    let(:builder) { FormBuilder.new(:resource, resource, helper, {}) }
    let(:parsed) { Nokogiri::HTML(output) }

    before do
      allow(Decidim).to receive(:available_locales).and_return available_locales
      allow(I18n.config).to receive(:enforce_available_locales).and_return(false)
    end

    describe "#editor" do
      context "when using default toolbar" do
        let(:output) do
          builder.editor :slug
        end

        it "renders a hidden field and a container for the editor" do
          expect(parsed.css(".editor input[type='hidden'][name='resource[slug]']")).not_to be_empty
          expect(parsed.css(".editor label")).not_to be_empty
          expect(parsed.css(".editor .editor-container[data-toolbar='basic']")).not_to be_empty
        end
      end

      context "when using full toolbar" do
        let(:output) do
          builder.editor :slug, toolbar: :full
        end

        it "renders a hidden field and a container for the editor" do
          expect(parsed.css(".editor input[type='hidden'][name='resource[slug]']")).not_to be_empty
          expect(parsed.css(".editor label")).not_to be_empty
          expect(parsed.css(".editor .editor-container[data-toolbar='full']")).not_to be_empty
        end
      end

      context "when a help text is defined" do
        let(:field) { "editor-input" }
        let(:help_text_text) { "This is the help" }
        let(:output) do
          builder.editor :slug, help_text: help_text_text
        end

        it_behaves_like "having a help text"
      end
    end

    describe "#translated" do
      context "when a text area field" do
        let(:output) do
          builder.translated :text_area, :name
        end

        it "renders a tabbed input for each field" do
          expect(parsed.css("label[for='resource_name']")).not_to be_empty

          expect(parsed.css("li.tabs-title a").count).to eq 3

          expect(parsed.css(".tabs-panel textarea[name='resource[name_ca]']")).not_to be_empty
          expect(parsed.css(".tabs-panel textarea[name='resource[name_en]']")).not_to be_empty
          expect(parsed.css(".tabs-panel textarea[name='resource[name_de__CH]']")).not_to be_empty
        end

        context "with a single locale" do
          let(:available_locales) { %w(en) }

          it "renders a single input" do
            expect(parsed.css("label[for='resource_name_en']")).not_to be_empty
            expect(parsed.css("textarea[name='resource[name_en]']")).not_to be_empty
          end

          it "does not render a dropdown" do
            expect(parsed.css("option")).to be_empty
          end

          context "when a help text is defined" do
            let(:field) { "textarea" }
            let(:help_text_text) { "This is the help" }
            let(:output) do
              builder.translated :text_area, :name, help_text: help_text_text
            end

            it_behaves_like "having a help text"
          end
        end

        context "when there are more than 4 locales" do
          let(:available_locales) { %w(ca en cs es de-CH) }

          it "renders dropdown with locales" do
            expect(parsed.css("option").count).to eq 5
          end
        end
      end

      context "when a text field with hashtaggable option" do
        let(:output) do
          available_locales.each do |loc|
            resource.name[loc] = "dummy name value #{loc}"
          end
          builder.translated :text_field, :name, hashtaggable: true
        end

        it "renders a multilingual input with correct value" do
          available_locales.each do |loc|
            expect(parsed.css("input[type='text'][value='dummy name value #{loc}']")).not_to be_empty
          end
        end

        context "with a single locale" do
          let(:available_locales) { %w(en) }

          it "renders a single input" do
            expect(parsed.css("input[type='text'][value]").first.attributes["value"].value).not_to be_empty
          end
        end
      end

      context "with an editor field" do
        let(:output) do
          builder.translated :editor, :short_description
        end

        it "renders a tabbed input hidden for each field and a container for the editor" do
          expect(parsed.css("label[for='resource_short_description']")).not_to be_empty

          expect(parsed.css("li.tabs-title a").count).to eq 3

          expect(parsed.css(".editor label[for='resource_short_description_en']").first).to be_nil

          expect(parsed.css(".tabs-panel .editor input[type='hidden'][name='resource[short_description_ca]']")).not_to be_empty
          expect(parsed.css(".tabs-panel .editor input[type='hidden'][name='resource[short_description_en]']")).not_to be_empty
          expect(parsed.css(".tabs-panel .editor input[type='hidden'][name='resource[short_description_de__CH]']")).not_to be_empty

          expect(parsed.css(".tabs-panel .editor .editor-container").count).to eq 3
        end

        context "with a single locale" do
          let(:available_locales) { %w(en) }

          it "renders a single input and a container for the editor" do
            expect(parsed.css(".editor input[type='hidden'][name='resource[short_description_en]']")).not_to be_empty
            expect(parsed.css(".editor label")).not_to be_empty
            expect(parsed.css(".editor .editor-container")).not_to be_empty
          end
        end
      end

      context "with an editor field hashtaggable" do
        let(:output) do
          builder.translated :editor, :short_description, hashtaggable: true
        end

        it "renders a tabbed input hidden for each field and a container for the editor" do
          expect(parsed.css("label")).not_to be_empty

          expect(parsed.css("li.tabs-title a").count).to eq 3
          expect(parsed.css(".editor").count).to eq 3

          expect(parsed.css(".editor label[for='resource_short_description_en']").first).to be_nil

          expect(parsed.css(".tabs-panel .editor input[type='hidden'][name='resource[short_description_ca]']")).not_to be_empty
          expect(parsed.css(".tabs-panel .editor input[type='hidden'][name='resource[short_description_en]']")).not_to be_empty
          expect(parsed.css(".tabs-panel .editor input[type='hidden'][name='resource[short_description_de__CH]']")).not_to be_empty

          expect(parsed.css(".tabs-panel .editor .editor-container").count).to eq 3
        end

        context "with a single locale" do
          let(:available_locales) { %w(en) }

          it "renders a single input and a container for the editor" do
            expect(parsed.css(".editor-container.js-hashtags").count).to eq 1
            expect(parsed.css(".editor input[type='hidden'][name='resource[short_description_en]']")).not_to be_empty
            expect(parsed.css(".editor label")).not_to be_empty
            expect(parsed.css(".editor .editor-container")).not_to be_empty
          end
        end
      end
    end

    describe "#select" do
      let(:options) { [%w(All all), %w(None none)] }
      let(:output) do
        builder.select :scopes, options
      end

      it "renders" do
        expect(output).to match(
          "<label for=\"resource_scopes\">Scopes" \
          "<select name=\"resource[scopes]\" id=\"resource_scopes\">" \
          "<option value=\"all\">All</option>\n" \
          "<option value=\"none\">None</option></select></label>"
        )
      end

      context "when a help text is defined" do
        let(:field) { "select" }
        let(:help_text_text) { "This is the help" }
        let(:output) do
          builder.select :scopes, options, help_text: help_text_text
        end

        it "renders" do
          expect(output).to match(
            "<label for=\"resource_scopes\">Scopes<span class=\"help-text\">This is the help</span>" \
            "<select name=\"resource[scopes]\" id=\"resource_scopes\">" \
            "<option value=\"all\">All</option>\n" \
            "<option value=\"none\">None</option></select></label>"
          )
        end

        it_behaves_like "having a help text"
      end
    end

    describe "#hashtaggable_text_field" do
      let(:output) do
        builder.hashtaggable_text_field :text_field, :name, "en", { autofocus: true, class: "js-hashtags", label: false }
      end

      it "renders" do
        expect(parsed.css("input#resource_name_en")).not_to be_empty
      end
    end

    describe "#check_box" do
      let(:output) do
        builder.check_box :name
      end

      it "renders the checkbox before the label text" do
        expect(output).to eq(
          '<label for="resource_name"><input name="resource[name]" type="hidden" value="0" autocomplete="off" />' \
          '<input type="checkbox" value="1" name="resource[name]" id="resource_name" />Name' \
          "</label>"
        )
      end

      context "when a help text is defined" do
        let(:field) { "input" }
        let(:help_text_text) { "This is the help" }
        let(:output) do
          builder.check_box :name, help_text: help_text_text
        end

        it "renders correctly" do
          expect(output).to eq(
            '<label for="resource_name"><input name="resource[name]" type="hidden" value="0" autocomplete="off" />' \
            '<input type="checkbox" value="1" name="resource[name]" id="resource_name" />Name' \
            "</label>" \
            '<span class="help-text">This is the help</span>'
          )
        end

        it "renders the help text" do
          expect(parsed.css(".help-text")).not_to be_empty
        end

        # Mind that we are not using the "having a help text" shared example
        # for #check_box, as in this case we actually want to show it after
        # the input
        it "renders the help text after the field" do
          expect(parsed.to_s.index("help-text")).to be > parsed.to_s.index(field)
        end

        it "renders the help text text only once" do
          expect(parsed.to_s.scan(/#{help_text_text}/).size).to eq 1
        end
      end
    end

    describe "#password_field" do
      let(:output) do
        builder.password_field :password, options
      end
      let(:options) { {} }

      it "renders the input type password" do
        expect(output).to eq('<label for="resource_password">Password<input autocomplete="off" class="input-group-field" type="password" name="resource[password]" id="resource_password" /></label>')
      end

      context "when autocomplete attribute is defined" do
        let(:options) { { autocomplete: "new-password" } }

        it "renders the input type password with given autocomplete attribute" do
          expect(output).to eq('<label for="resource_password">Password<input autocomplete="new-password" class="input-group-field" type="password" name="resource[password]" id="resource_password" /></label>')
        end
      end

      context "when a help text is defined" do
        let(:field) { "input" }
        let(:help_text_text) { "This is the help" }
        let(:output) do
          builder.password_field :slug, help_text: help_text_text
        end

        it_behaves_like "having a help text"
      end
    end

    describe "#date_field" do
      context "when the resource has errors" do
        before do
          resource.valid?
        end

        let(:output) do
          builder.date_field :born_at
        end

        it "renders the input with the proper class" do
          expect(parsed.css("input.is-invalid-input")).not_to be_empty
        end

        context "when a help text is defined" do
          let(:field) { "input" }
          let(:help_text_text) { "This is the help" }
          let(:output) do
            builder.date_field :born_at, help_text: help_text_text
          end

          it_behaves_like "having a help text"
        end
      end
    end

    describe "#datetime_field" do
      let(:output) do
        builder.datetime_field :start_time
      end

      context "when the resource has errors" do
        before do
          resource.valid?
        end

        it "renders the input with the proper class" do
          expect(parsed.css("input.is-invalid-input")).not_to be_empty
        end

        context "when a help text is defined" do
          let(:field) { "input" }
          let(:help_text_text) { "This is the help" }
          let(:output) do
            builder.datetime_field :born_at, help_text: help_text_text
          end

          it_behaves_like "having a help text"
        end
      end
    end

    describe "validations" do
      around do |example|
        previous_backend = I18n.backend
        I18n.backend = I18n::Backend::Simple.new
        example.run
        I18n.backend = previous_backend
      end

      context "when a field is required" do
        let(:output) do
          builder.text_field :name, required: true
        end

        it "adds an abide error element" do
          expect(parsed.css("span.form-error")).not_to be_empty
        end

        describe "translations" do
          subject { parsed.css("span.form-error").first.text }

          context "with no translations for the field" do
            it { is_expected.to eq("There is an error in this field.") }
          end

          context "with custom I18n for the class and attribute" do
            before do
              I18n.backend.store_translations(
                :en,
                decidim: {
                  forms: {
                    errors: {
                      dummy: {
                        name: "Name is required for Dummy"
                      }
                    }
                  }
                }
              )
            end

            it { is_expected.to eq("Name is required for Dummy") }
          end

          context "with custom I18n for the attribute" do
            before do
              I18n.backend.store_translations(
                :en,
                decidim: {
                  forms: {
                    errors: {
                      name: "Name is required"
                    }
                  }
                }
              )
            end

            it { is_expected.to eq("Name is required") }
          end

          context "with custom I18n for the attribute outside Decidim" do
            before do
              I18n.backend.store_translations(
                :en,
                forms: {
                  errors: {
                    name: "Name is required"
                  }
                }
              )
            end

            it { is_expected.to eq("Name is required") }
          end
        end
      end

      context "when a field has a validation pattern" do
        let(:output) do
          builder.text_field :name, pattern: "foo"
        end

        it "adds an abide error element" do
          expect(parsed.css("span.form-error")).not_to be_empty
        end
      end

      describe "max length" do
        let(:output) do
          builder.text_field :name, maxlength: 150
        end

        it "adds a pattern" do
          expect(parsed.css("input[pattern='^(.|[\n\r]){0,150}$']")).not_to be_empty
          expect(parsed.css("input[maxlength='150']")).not_to be_nil
        end
      end

      describe "min length" do
        let(:output) do
          builder.text_field :name, minlength: 150
        end

        it "adds a pattern" do
          expect(parsed.css("input[pattern='^(.|[\n\r]){150,}$']")).not_to be_empty
          expect(parsed.css("input[minlength='150']")).not_to be_nil
        end
      end

      context "when the form has validations" do
        context "with presence validation" do
          let(:output) do
            builder.text_field :slug
          end

          it "injects presence validations" do
            expect(parsed.css("input[required='required']")).not_to be_empty
          end

          it "injects a span to show an error" do
            expect(parsed.css("span.form-error")).not_to be_empty
          end

          context "when the validation has a condition and it is false" do
            let(:output) do
              builder.text_field :conditional_presence
            end

            it "does not inject the presence validations" do
              expect(parsed.css("input[required='required']")).to be_empty
            end

            it "does nto inject a span to show an error" do
              expect(parsed.css("span.form-error")).to be_empty
            end
          end

          context "without the proposals module" do
            before do
              allow(Object).to receive(:const_defined?).and_call_original
              allow(Object).to receive(:const_defined?).with(
                "ProposalLengthValidator"
              ).and_return(false)
              allow(builder).to receive(:find_validator).and_call_original
            end

            it "injects the validations and does not reference ProposalLengthValidator" do
              expect(builder).not_to receive(:find_validator).with(
                :number,
                ProposalLengthValidator
              )
              output # Calls the builder
            end
          end
        end

        context "with proposal length validation" do
          let(:output) do
            builder.text_field :proposal_title
          end

          it "injects a span to show an error" do
            expect(parsed.css("span.form-error")).not_to be_empty
          end

          context "when the validation has a condition and it is false" do
            let(:output) do
              builder.text_field :conditional_presence
            end

            it "does not inject the presence validations" do
              expect(parsed.css("input[required='required']")).to be_empty
            end

            it "does nto inject a span to show an error" do
              expect(parsed.css("span.form-error")).to be_empty
            end
          end
        end

        context "with min and max length" do
          let(:output) do
            builder.text_field :number
          end

          it "injects the validations" do
            expect(parsed.css("input[pattern='^(.|[\n\r]){10,30}$']")).not_to be_empty
          end

          it "injects a span to show an error" do
            expect(parsed.css("span.form-error")).not_to be_empty
          end
        end

        context "with min length" do
          let(:output) do
            builder.text_field :min_number
          end

          it "injects the validations" do
            expect(parsed.css("input[pattern='^(.|[\n\r]){10,}$']")).not_to be_empty
          end
        end

        context "with max length" do
          let(:output) do
            builder.text_field :max_number
          end

          it "injects the validations" do
            expect(parsed.css("input[pattern='^(.|[\n\r]){0,50}$']")).not_to be_empty
          end
        end
      end
    end

    describe "#upload" do
      let(:present?) { false }
      let(:filename) { "my_image.jpg" }
      let(:image?) { false }
      let(:blob) do
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::Dev.asset("city.jpeg")),
          filename:
        )
      end
      let(:id) { 1 }
      let(:url) { Rails.application.routes.url_helpers.rails_blob_url(blob, only_path: true) }
      let(:file) do
        double(
          blob:,
          id:,
          filename:,
          attached?: present?,
          attachment: double(
            blob:,
            image?: image?
          )
        )
      end
      let(:required) { false }
      let(:attributes) do
        {
          required:
        }
      end
      let(:output) do
        builder.upload(:image, attributes)
      end

      before do
        allow(resource).to receive(:image).and_return(file)
        allow(resource).to receive(:attached_uploader).and_return(uploader.new(resource, :image))
      end

      it "sets the form as multipart" do
        output
        expect(builder.multipart).to be_truthy
      end

      it "renders a file_field" do
        expect(parsed.css('input[type="file"]')).not_to be_empty
      end

      context "when it is an image" do
        let(:uploader) { Decidim::ImageUploader }
        let(:image?) { true }

        context "and it is present" do
          let(:present?) { true }

          it "renders an image with the current file url" do
            expect(parsed.css("img[src=\"#{url}\"]")).not_to be_empty
          end
        end
      end

      context "when it is not an image" do
        let(:filename) { "my_file.pdf" }
        let(:blob) do
          ActiveStorage::Blob.create_and_upload!(
            io: File.open(Decidim::Dev.asset("Exampledocument.pdf")),
            filename:
          )
        end

        context "and it is present" do
          let(:present?) { true }

          it "renders the filename" do
            expect(output).to include(%(<a class="w-full break-all mb-2" href="#{url}">#{filename}</a>))
          end

          it "does not render an image tag" do
            expect(parsed.css("img[src=\"#{url}\"]")).to be_empty
          end

          it "renders a link to the current file url" do
            expect(parsed.css("a[href=\"#{url}\"]")).not_to be_empty
          end
        end
      end

      context "when the file is present" do
        let(:present?) { true }

        it "renders the add file button" do
          expect(parsed.css("button[data-upload]")).not_to be_empty
        end
      end

      context "when :dimensions_info is passed as option" do
        let(:attributes) { { dimensions_info: { medium: { processor: :resize_to_fit, dimensions: [100, 100] } } } }
        let(:output) { builder.upload :image, attributes }

        it "renders help message" do
          html = output
          expect(html).to include("<li>This image will be resized to fit 100 x 100 px.</li>")
        end

        context "and it contains multiple values incorrectly ordered" do
          let(:attributes) do
            {
              dimensions_info: {
                medium: { processor: :resize_to_fit, dimensions: [100, 100] },
                smaller: { processor: :resize_and_pad, dimensions: [99, 99] },
                small: { processor: :resize_to_fit, dimensions: [32, 32] },
                tiny: { processor: :resize_and_pad, dimensions: [33, 33] }
              }
            }
          end

          it "renders the correctly sorted values" do
            html = output
            [
              "<li>This image will be resized and padded to 33 x 33 px.</li>",
              "<li>This image will be resized and padded to 99 x 99 px.</li>",
              "<li>This image will be resized to fit 32 x 32 px.</li>",
              "<li>This image will be resized to fit 100 x 100 px.</li>"
            ].each do |value|
              expect(html).to include(value)
            end
          end
        end
      end

      context "when :help_i18n_scope is passed as option" do
        let(:attributes) { { help_i18n_scope: "custom.scope" } }
        let(:output) { builder.upload :image, attributes }

        it "renders calls I18n.t() with the correct scope" do
          # Upload help messages
          allow(I18n).to receive(:t).with(:image, scope: "activemodel.attributes.dummy").and_return("Image")
          expect(I18n).to receive(:t).with("explanation", scope: "custom.scope", attribute: "Image")
          expect(I18n).to receive(:t).with("decidim.forms.upload.labels.add_image")
          expect(I18n).to receive(:t).with("decidim.forms.upload.labels.replace")
          expect(I18n).to receive(:t).with("message_1", scope: "custom.scope")
          expect(I18n).to receive(:t).with("message_2", scope: "custom.scope")
          output
        end
      end

      context "when :help_i18n_messages is passed as option" do
        let(:attributes) { { help_i18n_messages: %w(message_1 message_2 message_3) } }
        let(:output) { builder.upload :image, attributes }

        it "renders calls I18n.t() with the correct messages" do
          # Upload help messages
          expect(I18n).to receive(:t).with("decidim.forms.upload.labels.add_image")
          expect(I18n).to receive(:t).with("decidim.forms.upload.labels.replace")
          allow(I18n).to receive(:t).with(:image, scope: "activemodel.attributes.dummy").and_return("Image")
          expect(I18n).to receive(:t).with("explanation", scope: "decidim.forms.upload_help", attribute: "Image")
          expect(I18n).to receive(:t).with("message_1", scope: "decidim.forms.file_help.file")
          expect(I18n).to receive(:t).with("message_2", scope: "decidim.forms.file_help.file")
          expect(I18n).to receive(:t).with("message_3", scope: "decidim.forms.file_help.file")
          output
        end

        context "with only one message" do
          let(:attributes) { { help_i18n_messages: "message_1" } }
          let(:output) { builder.upload :image, attributes }

          it "renders calls I18n.t() with the correct messages" do
            # Upload help messages

            allow(I18n).to receive(:t).with(:image, scope: "activemodel.attributes.dummy").and_return("Image")
            expect(I18n).to receive(:t).with("explanation", scope: "decidim.forms.upload_help", attribute: "Image")
            expect(I18n).to receive(:t).with("message_1", scope: "decidim.forms.file_help.file")
            expect(I18n).not_to receive(:t).with("message_2", scope: "decidim.forms.file_help.file")
            output
          end
        end
      end
    end

    describe "#data_picker" do
      context "when used without options" do
        let(:options) { {} }
        let(:prompt_params) { {} }
        let(:output) do
          builder.data_picker(:scopes, options, prompt_params)
        end

        before do
          allow(helper).to receive(:render).and_return("[rendering]")
        end

        it "renders a hidden field and a container for the editor" do
          expect(parsed.css("label[for='resource_scopes']").text).to eq("Scopes")
        end

        context "when a help text is defined" do
          let(:field) { "rendering" }
          let(:help_text_text) { "This is the help" }
          let(:output) do
            builder.data_picker(:scopes, { help_text: help_text_text }, prompt_params)
          end

          it_behaves_like "having a help text"
        end
      end
    end

    # legacy form builder specs
    it "should display labels by default" do
      node = Capybara.string builder.text_field(:slug)
      expect(node).to have_css("label[for='resource_slug']", text: "Slug")
    end

    describe "label" do
      context "when there are not any errors and no class option is passed" do
        it "should not have a class attribute" do
          node = Capybara.string builder.text_field(:slug)
          expect(node).to have_css('label:not([class=""])')
        end
      end

      it "should not have error class multiple times" do
        allow(resource).to receive(:errors).and_return(slug: ["required"])
        node = Capybara.string builder.text_field(:slug)
        error_class = node.find("label")["class"].split(/\s+/).keep_if do |v|
          v == "is-invalid-label"
        end
        expect(error_class.size).to eq 1
      end
    end

    describe "input generators" do
      it "should generate text_field input without label" do
        node = builder.text_field(:slug, label: false)

        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label[for="resource_slug"]', text: "Slug")).to be_empty
        expect(parsed.css('input[type="text"][name="resource[slug]"]')).not_to be_empty

        expect(Capybara.string(node).find_field("resource_slug").value).to eq resource.slug
      end

      it "should generate text_field with class from options" do
        node = builder.text_field(:slug, class: "righteous")
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('input.righteous[type="text"][name="resource[slug]"]')).not_to be_empty
      end

      shared_examples "generates label for field_type" do |field_type, html_field_type|
        it "should generate #{field_type} input" do
          node = Capybara.string builder.send(field_type, :slug)
          expect(node).to have_css('label[for="resource_slug"]', text: "Slug")
          expect(node).to have_css("input[type='#{html_field_type}'][name='resource[slug]']")
          expect(node.find_field("resource_slug").value).to eq resource.slug
        end
      end

      describe "fields_with_label" do
        include_examples "generates label for field_type", :text_field, "text"
        include_examples "generates label for field_type", :password_field, "password"
        include_examples "generates label for field_type", :email_field, "email"
        include_examples "generates label for field_type", :url_field, "url"
        include_examples "generates label for field_type", :number_field, "number"
      end

      it "should generate phone_field input" do
        node = builder.phone_field(:slug)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css("label")).to be_empty
        expect(parsed.css('label[for="resource_slug"]', text: "Slug")).to be_empty
        expect(parsed.css('input[type="tel"][name="resource[slug]"]')).not_to be_empty
        expect(Capybara.string(node).find_field("resource_slug").value).to eq resource.slug
      end

      it "should generate text_area input" do
        node = builder.text_area(:slug)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label[for="resource_slug"]', text: "Slug")).not_to be_empty
        expect(parsed.css("textarea[name='resource[slug]']")).not_to be_empty
        expect(Capybara.string(node).find_field("resource_slug").value.strip).to eq ""
      end

      it "should generate file_field input" do
        node = builder.file_field(:slug)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label[for="resource_slug"]', text: "Slug")).not_to be_empty
        expect(parsed.css('input[type="file"][name="resource[slug]"]')).not_to be_empty
        expect(Capybara.string(node).find_field("resource_slug").value).to be_nil
      end

      it "should generate select input" do
        choices = [["Choice #1", :a], ["Choice #2", :b]]

        node = builder.select(:slug, choices)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label[for="resource_slug"]', text: "Slug")).not_to be_empty
        expect(parsed.css('select[name="resource[slug]"]')).not_to be_empty
        expect(parsed.css('select[name="resource[slug]"] option[value="a"]', text: "Choice #1")).not_to be_empty
        expect(parsed.css('select[name="resource[slug]"] option[value="b"]', text: "Choice #2")).not_to be_empty
      end

      it "should generate check_box input" do
        label = 'label[for="resource_slug"]'
        name = '[name="resource[slug]"]'

        node = builder.check_box(:slug)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css("#{label} input[type=\"hidden\"]#{name}[value=\"0\"]")).not_to be_empty
        expect(parsed.css("#{label} input[type=\"checkbox\"]#{name}")).not_to be_empty
        expect(parsed.css(label, text: "Slug")).not_to be_empty
      end

      it "should generate check_box input without a label" do
        node = builder.check_box(:scopes, label: false)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('input[type="hidden"][name="resource[scopes]"][value="0"]')).not_to be_empty
        expect(parsed.css('input[type="checkbox"][name="resource[scopes]"]')).not_to be_empty
        expect(parsed.css('label[for="resource_scopes"]')).to be_empty
      end

      it "should generate check_box input with a label with HTML content" do
        label_text = "Accepts terms and conditions"

        node = builder.check_box(:slug, label: "<a href='/'>#{label_text}</a>")
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label[for="resource_slug"] a', text: label_text)).not_to be_empty
      end

      it "should generate radio_button input" do
        node = builder.radio_button(:slug, "ok")
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label[for="resource_slug_ok"]')).not_to be_empty
        expect(parsed.css('input[type="radio"][name="resource[slug]"]')).not_to be_empty
      end

      it "should generate radio_button input with a label" do
        node = builder.radio_button(:slug, true, label: "Functioning")
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label[for="resource_slug_true"]', text: "Functioning")).not_to be_empty
        expect(parsed.css('input[type="radio"][name="resource[slug]"]')).not_to be_empty
      end

      it "should generate radio_button without a label" do
        node = builder.radio_button(:slug, "ok", label: false)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label[for="resource_slug_ok"]')).to be_empty
        expect(parsed.css('input[label="false"]')).to be_empty
        expect(parsed.css('input[type="radio"][name="resource[slug]"]')).not_to be_empty
      end

      it "should generate radio_button with label options" do
        node = builder.radio_button(:slug, "ok", class: "very", label_options: { class: "special" })
        parsed = Nokogiri::HTML(node)
        expect(parsed.css('label.special[for="resource_slug_ok"]')).not_to be_empty
        expect(parsed.css('input.very[type="radio"][name="resource[slug]"]')).not_to be_empty
      end

      it "should generate date_select input" do
        select = "select#resource_start_time_"
        option = 'option[selected="selected"]'
        resource.start_time = Time.zone.parse("1969-06-18 20:30")

        node = builder.label(:start_time) + builder.date_select(:start_time)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label[for="resource_start_time"]', text: "Start time")).not_to be_empty

        %w(1 2 3).each do |i|
          expect(parsed.css("select[name='resource[start_time(#{i}i)]']")).not_to be_empty
        end
        expect(parsed.css("#{select}1i #{option}[value=\"1969\"]")).not_to be_empty
        expect(parsed.css("#{select}2i #{option}[value=\"6\"]")).not_to be_empty
        expect(parsed.css("#{select}3i #{option}[value=\"18\"]")).not_to be_empty

        %w(4 5).each do |i|
          expect(parsed.css("select[name='resource[start_time(#{i}i)]']")).to be_empty
        end
      end

      it "should generate date_select input with :discard_year => true" do
        select = "select#resource_start_time_"
        option = 'option[selected="selected"]'
        resource.start_time = Time.zone.parse("1969-06-18 20:30")

        node = Capybara.string(
          builder.label(:start_time) +
            builder.date_select(:start_time, discard_year: true)
        )
        expect(node)
          .to have_css('label[for="resource_start_time"]', text: "Start time")
        %w(2 3).each do |i|
          expect(node).to have_css("select[name='resource[start_time(#{i}i)]']")
        end
        expect(node).to have_no_css("#{select}1i #{option}[value=\"1969\"]")
        expect(node).to have_css("#{select}2i #{option}[value=\"6\"]")
        expect(node).to have_css("#{select}3i #{option}[value=\"18\"]")
        %w(1 4 5).each do |i|
          expect(node)
            .to have_no_css("select[name='resource[start_time(#{i}i)]']")
        end
      end

      it "should generate datetime_select input" do
        select = "select#resource_start_time_"
        option = 'option[selected="selected"]'
        resource.start_time = Time.zone.parse("1969-06-18 20:30")

        node = Capybara.string(
          builder.label(:start_time) +
            builder.datetime_select(:start_time)
        )
        expect(node)
          .to have_css('label[for="resource_start_time"]', text: "Start time")
        %w(1 2 3 4 5).each do |i|
          expect(node).to have_css("select[name='resource[start_time(#{i}i)]']")
        end
        expect(node).to have_css("#{select}1i #{option}[value=\"1969\"]")
        expect(node).to have_css("#{select}2i #{option}[value=\"6\"]")
        expect(node).to have_css("#{select}3i #{option}[value=\"18\"]")
        expect(node).to have_css("#{select}4i #{option}[value=\"20\"]")
        expect(node).to have_css("#{select}5i #{option}[value=\"30\"]")
      end

      it "should generate datetime_select input with :discard_year => true" do
        select = "select#resource_start_time_"
        option = 'option[selected="selected"]'
        resource.start_time = Time.zone.parse("1969-06-18 20:30")

        node = builder.label(:birthdate) + builder.datetime_select(:start_time, discard_year: true)

        parsed = Nokogiri::HTML(node)
        expect(parsed.css('label[for="resource_start_time"]', text: "Start time")).not_to be_empty

        %w(2 3 4 5).each do |i|
          expect(parsed.css("select[name='resource[start_time(#{i}i)]']")).not_to be_empty
        end
        expect(parsed.css("#{select}1i #{option}[value=\"1969\"]")).to be_empty
        expect(parsed.css("select[name='author[birthdate(#1i)]']")).to be_empty
        expect(parsed.css("#{select}2i #{option}[value=\"6\"]")).not_to be_empty
        expect(parsed.css("#{select}3i #{option}[value=\"18\"]")).not_to be_empty
        expect(parsed.css("#{select}4i #{option}[value=\"20\"]")).not_to be_empty
        expect(parsed.css("#{select}5i #{option}[value=\"30\"]")).not_to be_empty
      end

      it "should generate time_zone_select input" do
        resource.slug = "Perth"
        node = builder.label(:slug) + builder.time_zone_select(:slug)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label[for="resource_slug"]', text: "Slug")).not_to be_empty
        expect(parsed.css('select[name="resource[slug]"]')).not_to be_empty
        expect(parsed.css('select[name="resource[slug]"] option[value="Perth"]',
                          text: "(GMT+08:00) Perth")).not_to be_empty
      end

      it "should generate date_field input" do
        resource.born_at = Date.new(2000, 1, 1)
        node = builder.date_field(:born_at)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label[for="resource_born_at"]', text: "Born at")).not_to be_empty
        expect(parsed.css('input[type="date"][name="resource[born_at]"]')).not_to be_empty
        expect(Capybara.string(node).find_field("resource_born_at").value).to eq resource.born_at.to_s
      end

      it "should generate datetime_field input" do
        start_time = Time.zone.parse("1969-06-18 20:30") + 42.years
        resource.start_time = start_time

        node = builder.datetime_field(:start_time)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label[for="resource_start_time"]', text: "Start time")).not_to be_empty
        expect(parsed.css('input[type^="datetime"][name="resource[start_time]"]')).not_to be_empty

        value = Time.zone.parse(Capybara.string(node).find_field("resource_start_time").value)
        expect(value).to eq start_time.to_s
      end

      it "should generate search_field" do
        node = builder.search_field(:slug)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label[for="resource_slug"]', text: "Slug")).not_to be_empty
        expect(parsed.css('input[type="search"][name="resource[slug]"]')).not_to be_empty

        expect(Capybara.string(node).find_field("resource_slug").value).to eq resource.slug
      end

      it "should generate color_field" do
        resource.slug = "#000000"
        node = builder.color_field(:slug)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label[for="resource_slug"]', text: "Slug")).not_to be_empty
        expect(parsed.css('input[type="color"][name="resource[slug]"]')).not_to be_empty
        expect(Capybara.string(node).find_field("resource_slug").value).to eq resource.slug
      end

      it "should generate collection_select input" do
        selector = 'select[name="resource[scopes]"] option'

        scopes = [
          Decidim::Scope.new(id: 78, name: "Gulliver's Travels"),
          Decidim::Scope.new(id: 133, name: "Treasure Island")
        ]
        allow(Decidim::Scope).to receive(:all).and_return(scopes)

        node = builder.collection_select(:scopes, Decidim::Scope.all, :id, :name)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label[for="resource_scopes"]', text: "Scopes")).not_to be_empty
        expect(parsed.css('select[name="resource[scopes]"]')).not_to be_empty
        expect(parsed.css("#{selector}[value=\"78\"]", text: "Gulliver's Travels")).not_to be_empty
        expect(parsed.css("#{selector}[value=\"133\"]", text: "Treasure Island")).not_to be_empty
      end

      describe "help_text" do
        it "should add a span element" do
          help_text = "Enter login"
          node = Capybara.string builder.text_field(:slug, help_text:)
          expect(node.find("span.help-text").text).to eq help_text
        end

        it "should not add help_text attribute" do
          node =
            Capybara.string builder.text_field(:slug, help_text: "Enter login")
          expect(node.find_field("resource_slug")["help_text"]).to be_nil
        end
      end

      context "when there are not any errors and no class option is passed" do
        it "should not have a class attribute" do
          node = Capybara.string builder.text_field(:slug)
          expect(node).to have_css('input:not([class=""])')
        end
      end
    end

    describe "errors generator" do
      it "should not display errors" do
        node = builder.text_field(:slug)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css("small.form-error", text: "required")).to be_empty
      end

      it "should display errors" do
        allow(resource).to receive(:errors).and_return(slug: ["required"])
        node = builder.text_field(:slug)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css("small.form-error", text: "required")).not_to be_empty
      end

      %w(file_field email_field text_field url_field number_field
         search_field color_field password_field).each do |field|
        it "should display errors on #{field} inputs" do
          allow(resource)
            .to receive(:errors).and_return(slug: ["required"])
          node = builder.public_send(field, :slug)
          parsed = Nokogiri::HTML(node)

          expect(parsed.css('label.is-invalid-label[for="resource_slug"]')).not_to be_empty
          expect(parsed.css('input.is-invalid-input[name="resource[slug]"]')).not_to be_empty
        end
      end

      %w(date_field datetime_field).each do |field|
        it "should display errors on #{field} as date inputs" do
          allow(resource)
            .to receive(:errors).and_return(born_at: ["required"])
          node = builder.public_send(field, :born_at)
          parsed = Nokogiri::HTML(node)

          expect(parsed.css('label.is-invalid-label[for="resource_born_at"]')).not_to be_empty
          expect(parsed.css('input.is-invalid-input[name="resource[born_at]"]')).not_to be_empty
        end
      end

      it "should display errors on text_area inputs" do
        allow(resource).to receive(:errors).and_return(slug: ["required"])
        node = builder.text_area(:slug)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label.is-invalid-label[for="resource_slug"]')).not_to be_empty
        expect(parsed.css('textarea.is-invalid-input[name="resource[slug]"]')).not_to be_empty
      end

      it "should display errors on select inputs" do
        allow(resource)
          .to receive(:errors).and_return(scopes: ["required"])
        node = builder.select(:scopes, [["Choice #1", :a], ["Choice #2", :b]])
        parsed = Nokogiri::HTML(node)
        expect(parsed.css('label.is-invalid-label[for="resource_scopes"]')).not_to be_empty
        expect(parsed.css('select.is-invalid-input[name="resource[scopes]"]')).not_to be_empty
      end

      it "should display errors on date_select inputs" do
        allow(resource).to receive(:errors).and_return(born_at: ["required"])
        node = builder.date_select(:born_at)
        parsed = Nokogiri::HTML(node)
        expect(parsed.css('label.is-invalid-label[for="resource_born_at"]')).not_to be_empty

        %w(1 2 3).each do |i|
          expect(parsed.css("select.is-invalid-input[name='resource[born_at(#{i}i)]']")).not_to be_empty
        end
      end

      it "should display errors on datetime_select inputs" do
        allow(resource).to receive(:errors).and_return(born_at: ["required"])
        node = builder.datetime_select(:born_at)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label.is-invalid-label[for="resource_born_at"]')).not_to be_empty

        %w(1 2 3 4 5).each do |i|
          expect(parsed.css("select.is-invalid-input[name='resource[born_at(#{i}i)]']")).not_to be_empty
        end
      end

      it "should display errors on time_zone_select inputs" do
        allow(resource).to receive(:errors).and_return(born_at: ["required"])
        node = builder.time_zone_select(:born_at)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label.is-invalid-label[for="resource_born_at"]')).not_to be_empty
        expect(parsed.css('select.is-invalid-input[name="resource[born_at]"]')).not_to be_empty
      end

      it "should display errors on collection_select inputs" do
        allow(resource)
          .to receive(:errors).and_return(scopes: ["required"])
        node = builder.collection_select(:scopes, Decidim::Scope.all, :id, :title)
        parsed = Nokogiri::HTML(node)

        expect(parsed.css('label.is-invalid-label[for="resource_scopes"]')).not_to be_empty
        expect(parsed.css('select.is-invalid-input[name="resource[scopes]"]')).not_to be_empty
      end

      # N.B. check_box and radio_button inputs do not have the is-invalid-input
      # class applied
      it "should display HTML errors when the option is specified" do
        slug = ['required <a href="link_target">link</a>']

        allow(resource).to receive(:errors).and_return(slug:)
        node = Capybara.string(
          builder.text_field(:slug, html_safe_errors: true)
        )
        expect(node).to have_link("link", href: "link_target")
      end

      it "should not display HTML errors when the option is not specified" do
        slug = ['required <a href="link_target">link</a>']

        allow(resource).to receive(:errors).and_return(slug:)
        node = Capybara.string builder.text_field(:slug)
        expect(node).to have_no_link("link", href: "link")
      end

      context "when class option given" do
        it "should add it to the error class" do
          allow(resource).to receive(:errors).and_return(slug: ["required"])
          node = builder.text_field(:slug, class: "righteous")
          parsed = Nokogiri::HTML(node)

          expect(parsed.css('input.righteous.is-invalid-input[name="resource[slug]"]')).not_to be_empty
        end
      end

      context "when invalid class option given" do
        it "should add it to the error class" do
          allow(resource).to receive(:errors).and_return(slug: ["required"])
          node = builder.text_field(:slug, class: :illgotten)
          parsed = Nokogiri::HTML(node)

          expect(parsed.css('input.illgotten.is-invalid-input[name="resource[slug]"]')).not_to be_empty
        end
      end
    end

    describe "submit button generator" do
      context "when button_class config is not set" do
        it "should display form button with default class" do
          node = builder.submit("Save")
          parsed = Nokogiri::HTML(node)

          expect(parsed.css('input[type="submit"][class="button"]')).not_to be_empty
        end
      end

      context 'when option value is "superduper"' do
        it "should display form button with 'superduper' class" do
          node = builder.submit("Save", class: "superduper")
          parsed = Nokogiri::HTML(node)

          expect(parsed.css('input[type="submit"][class="superduper"]')).not_to be_empty
        end
      end
    end
  end
end
