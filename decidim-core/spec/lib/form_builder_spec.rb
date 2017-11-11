# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

module Decidim
  describe FormBuilder do
    let(:helper) { Class.new(ActionView::Base).new }
    let(:available_locales) { %w(ca en de-CH) }

    let(:resource) do
      Class.new do
        def self.model_name
          ActiveModel::Name.new(self, nil, "dummy")
        end

        extend ActiveModel::Translation
        include ActiveModel::Model
        include Virtus.model
        include TranslatableAttributes

        attribute :slug, String
        attribute :category_id, Integer
        attribute :number, Integer
        attribute :max_number, Integer
        attribute :min_number, Integer
        attribute :conditional_presence, String
        attribute :image

        translatable_attribute :name, String
        translatable_attribute :short_description, String

        validates :slug, presence: true
        validates :number, length: { minimum: 10, maximum: 30 }
        validates :max_number, length: { maximum: 50 }
        validates :min_number, length: { minimum: 10 }
        validates :conditional_presence, presence: true, if: :validate_presence

        def validate_presence
          false
        end
      end.new
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
          expect(parsed.css(".editor input[type='hidden'][name='resource[slug]']").first).to be
          expect(parsed.css(".editor label[for='resource_slug']").first).to be
          expect(parsed.css(".editor .editor-container[data-toolbar='basic']").first).to be
        end
      end

      context "when using full toolbar" do
        let(:output) do
          builder.editor :slug, toolbar: :full
        end

        it "renders a hidden field and a container for the editor" do
          expect(parsed.css(".editor input[type='hidden'][name='resource[slug]']").first).to be
          expect(parsed.css(".editor label[for='resource_slug']").first).to be
          expect(parsed.css(".editor .editor-container[data-toolbar='full']").first).to be
        end
      end
    end

    describe "#translated" do
      context "when a text area field" do
        let(:output) do
          builder.translated :text_area, :name
        end

        it "renders a tabbed input for each field" do
          expect(parsed.css("label[for='resource_name']").first).to be

          expect(parsed.css("li.tabs-title a").count).to eq 3

          expect(parsed.css(".tabs-panel textarea[name='resource[name_ca]']").first).to be
          expect(parsed.css(".tabs-panel textarea[name='resource[name_en]']").first).to be
          expect(parsed.css(".tabs-panel textarea[name='resource[name_de__CH]']").first).to be
        end

        context "with a single locale" do
          let(:available_locales) { %w(en) }

          it "renders a single input" do
            expect(parsed.css("label[for='resource_name_en']").first).to be
            expect(parsed.css("textarea[name='resource[name_en]']").first).to be
          end
        end
      end

      context "with an editor field" do
        let(:output) do
          builder.translated :editor, :short_description
        end

        it "renders a tabbed input hidden for each field and a container for the editor" do
          expect(parsed.css("label[for='resource_short_description']").first).to be

          expect(parsed.css("li.tabs-title a").count).to eq 3

          expect(parsed.css(".editor label[for='resource_short_description_en']").first).to be_nil

          expect(parsed.css(".tabs-panel .editor input[type='hidden'][name='resource[short_description_ca]']").first).to be
          expect(parsed.css(".tabs-panel .editor input[type='hidden'][name='resource[short_description_en]']").first).to be
          expect(parsed.css(".tabs-panel .editor input[type='hidden'][name='resource[short_description_de__CH]']").first).to be

          expect(parsed.css(".tabs-panel .editor .editor-container").count).to eq 3
        end

        context "with a single locale" do
          let(:available_locales) { %w(en) }

          it "renders a single input and a container for the editor" do
            expect(parsed.css(".editor input[type='hidden'][name='resource[short_description_en]']").first).to be
            expect(parsed.css(".editor label[for='resource_short_description_en']").first).to be
            expect(parsed.css(".editor .editor-container").first).to be
          end
        end
      end
    end

    describe "categories_for_select" do
      subject { Nokogiri::HTML(output) }

      let!(:feature) { create(:feature) }
      let!(:category) { create(:category, name: { "en" => "Nice category" }, participatory_space: feature.participatory_space) }
      let!(:other_category) { create(:category, name: { "en" => "A better category" }, participatory_space: feature.participatory_space) }
      let!(:subcategory) { create(:category, name: { "en" => "Subcategory" }, parent: category, participatory_space: feature.participatory_space) }
      let(:scope) { feature.categories }

      let(:options) { {} }
      let(:output) { builder.categories_select(:category_id, scope, options) }

      it "includes all the categories" do
        values = subject.css("option").map(&:text)

        expect(subject.css("option").count).to eq(3)
        expect(values).to include(category.name["en"])
        expect(values).to include("- #{subcategory.name["en"]}")
        expect(values).to include(other_category.name["en"])
      end

      context "when a category has subcategories" do
        context "when `disable_parents` is true" do
          it "is disabled" do
            expect(subject.xpath("//option[@disabled='disabled']").count).to eq(1)
            expect(subject.xpath("//option[@disabled='disabled']").first.text).to eq(category.name["en"])
          end
        end

        context "when `disable_parents` is false" do
          let(:options) { { disable_parents: false } }

          it "is not disabled" do
            expect(subject.xpath("//option[@disabled='disabled']").count).to eq(0)
          end
        end
      end

      it "sorts main categories by name" do
        expect(subject.css("option")[0].text).to eq(other_category.name["en"])
        expect(subject.css("option")[1].text).to eq(category.name["en"])
      end

      it "sorts subcategories by name" do
        subcategory2 = create(:category, name: { "en" => "First subcategory" }, parent: category, participatory_space: feature.participatory_space)

        expect(subject.css("option")[2].text).to eq("- #{subcategory2.name["en"]}")
        expect(subject.css("option")[3].text).to eq("- #{subcategory.name["en"]}")
      end

      context "when given a prompt" do
        let(:options) { { prompt: "Select something" } }

        it "includes it as an option" do
          expect(subject.css("option")[0].text).to eq("Select something")
          expect(subject.css("option").count).to eq(4)
        end
      end
    end

    describe "checkbox" do
      let(:output) do
        builder.check_box :name
      end

      it "renders the checkbox before the label text" do
        expect(output).to eq(
          '<label for="resource_name"><input name="resource[name]" type="hidden" value="0" />' \
            '<input type="checkbox" value="1" name="resource[name]" id="resource_name" />Name' \
          "</label>"
        )
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
          expect(parsed.css("span.form-error").first).to be
        end

        describe "translations" do
          subject { parsed.css("span.form-error").first.text }

          context "with no translations for the field" do
            it { is_expected.to eq("There's an error in this field.") }
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
          expect(parsed.css("span.form-error").first).to be
        end
      end

      describe "max length" do
        let(:output) do
          builder.text_field :name, maxlength: 150
        end

        it "adds a pattern" do
          expect(parsed.css("input[pattern='^(.|[\n\r]){0,150}$']").first).to be
          expect(parsed.css("input[maxlength='150']")).to be
        end
      end

      describe "min length" do
        let(:output) do
          builder.text_field :name, minlength: 150
        end

        it "adds a pattern" do
          expect(parsed.css("input[pattern='^(.|[\n\r]){150,}$']").first).to be
          expect(output).not_to include("minlength")
        end
      end

      context "when the form has validations" do
        context "with presence validation" do
          let(:output) do
            builder.text_field :slug
          end

          it "injects presence validations" do
            expect(parsed.css("input[required='required']").first).to be
          end

          it "injects a span to show an error" do
            expect(parsed.css("span.form-error").first).to be
          end

          context "when the validation has a condition and it is false" do
            let(:output) do
              builder.text_field :conditional_presence
            end

            it "does not inject the presence validations" do
              expect(parsed.css("input[required='required']").first).not_to be
            end

            it "does nto inject a span to show an error" do
              expect(parsed.css("span.form-error").first).not_to be
            end
          end
        end

        context "with min and max length " do
          let(:output) do
            builder.text_field :number
          end

          it "injects the validations" do
            expect(parsed.css("input[pattern='^(.|[\n\r]){10,30}$']").first).to be
          end

          it "injects a span to show an error" do
            expect(parsed.css("span.form-error").first).to be
          end
        end

        context "with min length " do
          let(:output) do
            builder.text_field :min_number
          end

          it "injects the validations" do
            expect(parsed.css("input[pattern='^(.|[\n\r]){10,}$']").first).to be
          end
        end

        context "with max length " do
          let(:output) do
            builder.text_field :max_number
          end

          it "injects the validations" do
            expect(parsed.css("input[pattern='^(.|[\n\r]){0,50}$']").first).to be
          end
        end
      end
    end

    describe "upload" do
      let(:present?) { false }
      let(:content_type) { nil }
      let(:filename) { "my_image.jpg" }
      let(:url) { "/some/file/path/#{filename}" }
      let(:file) do
        double(
          url: url,
          present?: present?,
          content_type: content_type,
          file: double(
            filename: filename
          )
        )
      end
      let(:optional) { true }
      let(:attributes) do
        {
          optional: optional
        }
      end
      let(:output) do
        builder.upload :image, attributes
      end

      before do
        allow(resource).to receive(:image).and_return(file)
      end

      it "sets the form as multipart" do
        output
        expect(builder.multipart).to be_truthy
      end

      it "renders a file_field" do
        expect(parsed.css('input[type="file"]').first).to be
      end

      context "when it is an image" do
        context "and it is not present" do
          it "renders the 'Default image' label" do
            expect(output).to include("Default image")
          end
        end

        context "and it is present" do
          let(:present?) { true }

          it "renders the 'Current image' label" do
            expect(output).to include("Current image")
          end

          it "renders an image with the current file url" do
            expect(parsed.css('img[src="' + url + '"]').first).to be
          end
        end
      end

      context "when it is not an image" do
        let(:filename) { "my_file.pdf" }

        context "and it is present" do
          let(:present?) { true }

          it "renders the 'Current file' label" do
            expect(output).to include("Current file")
          end

          it "doesn't render an image tag" do
            expect(parsed.css('img[src="' + url + '"]').first).not_to be
          end

          it "renders a link to the current file url" do
            expect(parsed.css('a[href="' + url + '"]').first).to be
          end
        end
      end

      context "when the file is present" do
        let(:present?) { true }

        it "renders the delete checkbox" do
          expect(parsed.css('input[type="checkbox"]').first).to be
        end

        context "when the optional argument is false" do
          let(:optional) { false }

          it "doesn't render the delete checkbox" do
            expect(parsed.css('input[type="checkbox"]').first).not_to be
          end
        end
      end
    end
  end
end
