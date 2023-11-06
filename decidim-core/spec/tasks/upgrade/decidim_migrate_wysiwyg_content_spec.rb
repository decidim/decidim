# frozen_string_literal: true

require "spec_helper"

describe "Wysiwyg migration" do
  describe "rake decidim:upgrade:register_wysiwyg_migration", type: :task do
    context "when executing task" do
      it "does not throw exceptions keys" do
        expect do
          Rake::Task[:"decidim:upgrade:register_wysiwyg_migration"].invoke
        end.not_to raise_exception
      end
    end
  end

  describe "rake decidim:upgrade:migrate_wysiwyg_content", type: :task do
    context "when executing task" do
      # Different types of contents are tested already at the migrator test.
      # The rake task spec is just to test that the content is migrated for all
      # the registered models correctly.
      let(:original_content) do
        <<~HTML
          <h2>Title of the content</h2>
          <p>This is a test content for the migrator.</p>
          <p class="ql-indent-1">We should support indentation</p>
          <p class="ql-indent-5">We should support indentation at all levels.</p>
        HTML
      end
      let(:expected_content) do
        <<~HTML
          <h2>Title of the content</h2>
          <p>This is a test content for the migrator.</p>
          <p class="editor-indent-1">We should support indentation</p>
          <p class="editor-indent-5">We should support indentation at all levels.</p>
        HTML
      end

      before do
        Rake::Task[:"decidim:upgrade:register_wysiwyg_migration"].invoke
      end

      it "migrates the content for every field" do
        records = {}
        Decidim::Upgrade::WysiwygMigrator.model_registry.each do |model|
          factory = nil
          FactoryBot.factories.each do |item|
            factory = item if item.send(:class_name) == model[:class].name
          end
          # Would need to load all factories from all modules for them to be
          # available.
          next unless factory

          records[model[:class].name] ||= create(factory.name)
          records[model[:class].name].update!(
            model[:columns].index_with { { en: original_content } }
          )
        end

        Rake::Task[:"decidim:upgrade:migrate_wysiwyg_content"].invoke

        Decidim::Upgrade::WysiwygMigrator.model_registry.each do |model|
          record = records[model[:class].name]
          next unless record

          record.reload
          model[:columns].each do |col|
            value = record.public_send(col)
            expect(value["en"]).to eq(expected_content)
          end
        end
      end
    end
  end
end
