# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Upgrade::WysiwygMigrator do
    let(:migrator) { described_class.new(content) }

    let(:organization) { create(:organization) }
    let(:component) { create(:component, organization:) }
    let(:image) { create(:attachment, attached_to: organization) }

    let(:content) { original_content }
    let(:original_content) do
      <<~HTML.gsub(/\n\s*/, "")
        <h2>Title of the content</h2>
        <p>This is a test content for the migrator.</p>
        <p class="ql-indent-1">We should support indentation</p>
        <p class="ql-indent-5">We should support indentation at all levels.</p>
        <h3>Below we will show some lists</h3>
        <ul>
          <li>Item 1</li>
          <li class="ql-indent-3">Item 1.1.1.1</li>
          <li>Item 2</li>
          <li class="ql-indent-1">Item 2.1</li>
          <li class="ql-indent-1">Item 2.2</li>
          <li class="ql-indent-2">Item 2.2.1</li>
          <li class="ql-indent-2">Item 2.2.2</li>
          <li class="ql-indent-1">Item 2.3</li>
          <li class="ql-indent-1">Item 2.4</li>
        </ul>
        <p><br></p>
        <ol>
          <li>Item 1</li>
          <li class="ql-indent-3">Item 1.1.1.1</li>
          <li>Item 2</li>
          <li class="ql-indent-1">Item 2.1</li>
          <li class="ql-indent-1">Item 2.2</li>
          <li class="ql-indent-2">Item 2.2.1</li>
          <li class="ql-indent-2">Item 2.2.2</li>
          <li class="ql-indent-1">Item 2.3</li>
          <li class="ql-indent-1">Item 2.4</li>
        </ol>
        <ul>
          <li class="ql-indent-3">Item 1.1.1.1</li>
        </ul>
        <p>
          Paragraph content with an inline image.
          <img src="#{image.url}">
          And some text after that.
        </p>
        <p><img src="#{image.url}" alt="This image had an alternative text"></p>
        <iframe class="ql-video" frameborder="0" allowfullscreen="true" src="https://www.youtube.com/embed/f6JMgJAQ2tc?showinfo=0"></iframe>
        <div><span>Here we had some unrecognized node.</span></div>
        <blockquote>Blockquote element content <br>should be <strong>wrapped inside</strong> a paragraph.</blockquote>
        <p>Code segments such as... <code>{"foo": "bar"}</code> ...have been converted to code blocks.</p>
        <p>This is the end of the document.</p>
      HTML
    end
    let(:expected_content) do
      <<~HTML.gsub(/\n\s*/, "")
        <h2>Title of the content</h2>
        <p>This is a test content for the migrator.</p>
        <p class="editor-indent-1">We should support indentation</p>
        <p class="editor-indent-5">We should support indentation at all levels.</p>
        <h3>Below we will show some lists</h3>
        <ul>
          <li>
            <p>Item 1</p>
            <ul>
              <li>
                <p></p>
                <ul>
                  <li>
                    <p></p>
                    <ul>
                      <li><p>Item 1.1.1.1</p></li>
                    </ul>
                  </li>
                </ul>
              </li>
            </ul>
          </li>
          <li>
            <p>Item 2</p>
            <ul>
              <li><p>Item 2.1</p></li>
              <li>
                <p>Item 2.2</p>
                <ul>
                  <li><p>Item 2.2.1</p></li>
                  <li><p>Item 2.2.2</p></li>
                </ul>
              </li>
              <li><p>Item 2.3</p></li>
              <li><p>Item 2.4</p></li>
            </ul>
          </li>
        </ul>
        <p><br></p>
        <ol>
          <li>
            <p>Item 1</p>
            <ol>
              <li>
                <p></p>
                <ol>
                  <li>
                    <p></p>
                    <ol>
                      <li><p>Item 1.1.1.1</p></li>
                    </ol>
                  </li>
                </ol>
              </li>
            </ol>
          </li>
          <li>
            <p>Item 2</p>
            <ol>
              <li><p>Item 2.1</p></li>
              <li>
                <p>Item 2.2</p>
                <ol>
                  <li><p>Item 2.2.1</p></li>
                  <li><p>Item 2.2.2</p></li>
                </ol>
              </li>
              <li><p>Item 2.3</p></li>
              <li><p>Item 2.4</p></li>
            </ol>
          </li>
        </ol>
        <ul>
          <li>
            <p></p>
            <ul>
              <li>
                <p></p>
                <ul>
                  <li>
                    <p></p>
                    <ul>
                      <li><p>Item 1.1.1.1</p></li>
                    </ul>
                  </li>
                </ul>
              </li>
            </ul>
          </li>
        </ul>
        <p>Paragraph content with an inline image.</p>
        <div class="editor-content-image" data-image="">
          <img src="#{image.url}" alt="">
        </div>
        <p>And some text after that.</p>
        <div class="editor-content-image" data-image="">
          <img src="#{image.url}" alt="This image had an alternative text">
        </div>
        <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/embed/f6JMgJAQ2tc?showinfo=0">
          <div>
            <iframe src="https://www.youtube.com/embed/f6JMgJAQ2tc?showinfo=0" title="" frameborder="0" allowfullscreen="true"></iframe>
          </div>
        </div>
        <div><span>Here we had some unrecognized node.</span></div>
        <blockquote><p>Blockquote element content <br>should be <strong>wrapped inside</strong> a paragraph.</p></blockquote>
        <p>Code segments such as... </p>
        <pre>
          <code>{"foo": "bar"}</code>
        </pre>
        <p> ...have been converted to code blocks.</p>
        <p>This is the end of the document.</p>
      HTML
    end

    before do
      described_class.remove_instance_variable(:@model_registry) if described_class.instance_variable_defined?(:@model_registry)
    end

    shared_examples "HTML content migration" do
      subject { migrator.run }

      it "converts the content structure correctly" do
        expect(subject).to eq(expected_content)
      end

      context "when the content has already been converted" do
        let(:content) { expected_content }

        it "does not change the content" do
          expect(subject).to eq(expected_content)
        end
      end
    end

    describe "#run" do
      subject { migrator.run }

      it_behaves_like "HTML content migration"
    end

    describe ".convert" do
      subject { described_class.convert(content) }

      it_behaves_like "HTML content migration"

      context "when a hash is passed as the content" do
        let(:content) { { en: original_content, es: "<p>Castellano</p>#{original_content}" } }

        it "converts the content of each hash value" do
          expect(subject).to eq(en: expected_content, es: "<p>Castellano</p>#{expected_content}")
        end
      end
    end

    describe ".register_model" do
      it "registers a model" do
        Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Organization", [:description])

        expect(described_class.model_registry).to eq(
          [{ class: Decidim::Organization, columns: [:description] }]
        )
      end

      context "when the model is not defined" do
        it "does not register a model" do
          Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::FooBar", [:description])

          expect(described_class.model_registry).to eq([])
        end
      end
    end

    describe ".batch_range" do
      let(:data) { [*1..100] }

      it "generates the correct ranges for the provided indexes" do
        expect(described_class.batch_range(0, data)).to eq(1..100)
        expect(described_class.batch_range(1, data)).to eq(101..200)
        expect(described_class.batch_range(2, data)).to eq(201..300)
      end
    end

    describe ".update_records_batches" do
      let!(:data) { create_list(:dummy_resource, 149, component:) }
      let(:klass) { Decidim::DummyResources::DummyResource }
      let(:value_converter) do
        lambda do |_v, column|
          if column == :title
            { "en" => "Foobar", "machine_translations" => { "es" => "Foobar ES" } }
          else
            "Baz"
          end
        end
      end

      it "updates the given columns with the value converter" do
        expect do |block|
          described_class.update_records_batches(
            klass.where(component:),
            [:title, :body],
            value_converter,
            &block
          )
        end.to yield_successive_args([klass, 1..100], [klass, 101..150])

        klass.where(component:).each do |record|
          expect(record.title).to eq("en" => "Foobar", "machine_translations" => { "es" => "Foobar ES" })
          expect(record.body).to eq("Baz")
        end
      end
    end

    describe ".convert_model_data" do
      let!(:data) { create_list(:dummy_resource, 12, component:) }
      let(:query) { Decidim::DummyResources::DummyResource.where(component:).order(:id) }
      let(:converted_title) { { "en" => "Foobar", "machine_translations" => { "es" => "Foobar ES" } } }
      let(:converted_body) { "Baz" }

      it "converts the model data correctly" do
        data = described_class.convert_model_data(query, [:title, :body]) do |_v, column|
          if column == :title
            converted_title
          else
            converted_body
          end
        end

        expect(data).to eq(
          query.pluck(:id).index_with { { "title" => converted_title, "body" => converted_body } }
        )
      end
    end

    describe ".hash_subkey" do
      let(:hash) { { "foo" => { "bar" => "baz" } } }

      context "when no subkey is given" do
        it "yields the hash itself" do
          expect { |b| described_class.hash_subkey(hash, &b) }.to yield_with_args(hash)
        end

        context "when the hash is empty" do
          let(:hash) { {} }

          it "does not yield" do
            expect { |b| described_class.hash_subkey(hash, &b) }.not_to yield_control
          end
        end
      end

      context "when a subkey is given" do
        it "yields the value of the subkey" do
          expect { |b| described_class.hash_subkey(hash, "foo", &b) }.to yield_with_args(hash["foo"])
        end

        context "when the subkey does not contain a value" do
          it "does not yield" do
            expect { |b| described_class.hash_subkey(hash, "baz", &b) }.not_to yield_control
          end
        end
      end
    end

    describe ".update_models" do
      let!(:data) { create_list(:dummy_resource, 149, title: { en: content }, component:) }
      let(:klass) { Decidim::DummyResources::DummyResource }

      before do
        described_class.register_model(klass, [:title])
      end

      it "updates the registered model columns" do
        described_class.update_models

        klass.where(component:).each do |record|
          expect(record.title).to eq("en" => expected_content)
        end
      end
    end

    describe ".update_settings" do
      let(:participatory_process) { component.participatory_space }
      let!(:step) { create(:participatory_process_step, participatory_process:) }

      before do
        component.settings = {
          dummy_global_translatable_text: { en: content }
        }
        component.step_settings = {
          step.id => {
            dummy_step_translatable_text: { en: content }
          }
        }
        component.save!
        component.reload
      end

      # settings.attribute :dummy_global_translatable_text, type: :text, translated: true, editor: true, required: true
      # settings.attribute :dummy_step_translatable_text, type: :text, translated: true, editor: true, required: true
      it "changes the settings attributes" do
        described_class.update_settings(
          Decidim::Component.where(id: component.id),
          { global: [:dummy_global_translatable_text], steps: { type: :multi, keys: [:dummy_step_translatable_text] } }
        )

        component.reload
        settings = component.attributes["settings"]
        expect(settings["global"]["dummy_global_translatable_text"]).to eq(
          "en" => expected_content
        )
        expect(settings["steps"][step.id.to_s]["dummy_step_translatable_text"]).to eq(
          "en" => expected_content
        )
      end
    end

    describe ".editor_attributes_for" do
      subject { described_class.editor_attributes_for(manifest) }

      let(:manifest) { component.manifest }

      it "returns both global and step editor attributes" do
        expect(subject).to eq(
          global: ["dummy_global_translatable_text"],
          step: ["dummy_step_translatable_text"]
        )
      end

      context "with only global editor settings" do
        let(:manifest) do
          Decidim::ComponentManifest.new.tap do |manifest|
            manifest.settings(:global) do |settings|
              settings.attribute :example, type: :string, translated: true, editor: true
            end
          end
        end

        it "returns only the global editor settings" do
          expect(subject).to eq(global: ["example"])
        end
      end

      context "with only step editor settings" do
        let(:manifest) do
          Decidim::ComponentManifest.new.tap do |manifest|
            manifest.settings(:step) do |settings|
              settings.attribute :example, type: :string, translated: true, editor: true
            end
          end
        end

        it "returns only the step editor settings" do
          expect(subject).to eq(step: ["example"])
        end
      end

      context "with no editor settings" do
        let(:manifest) { Decidim::ComponentManifest.new }

        it "returns an empty hash" do
          expect(subject).to eq({})
        end
      end
    end

    describe ".update_component_settings" do
      let(:participatory_process) { component.participatory_space }
      let!(:step) { create(:participatory_process_step, participatory_process:) }

      before do
        component.settings = {
          dummy_global_translatable_text: { en: content }
        }
        component.step_settings = {
          step.id => {
            dummy_step_translatable_text: { en: content }
          }
        }
        component.save!
        component.reload

        allow(Decidim).to receive(:component_manifests).and_return([component.manifest])
      end

      it "updates the component settings for all defined manifets" do
        expect { |b| described_class.update_component_settings(&b) }.to yield_with_args(:dummy, 1..1)

        component.reload
        settings = component.attributes["settings"]
        expect(settings["global"]["dummy_global_translatable_text"]).to eq(
          "en" => expected_content
        )
        expect(settings["steps"][step.id.to_s]["dummy_step_translatable_text"]).to eq(
          "en" => expected_content
        )
      end
    end
  end
end
