# frozen_string_literal: true

module Decidim
  module Core
    module ContentBlocks
      class RegistryManager
        def self.register_homepage_content_blocks!
          Decidim.content_blocks.register(:homepage, :hero) do |content_block|
            content_block.cell = "decidim/content_blocks/hero"
            content_block.settings_form_cell = "decidim/content_blocks/hero_settings_form"
            content_block.public_name_key = "decidim.content_blocks.hero.name"

            content_block.images = [
              {
                name: :background_image,
                uploader: "Decidim::HomepageImageUploader"
              }
            ]

            content_block.settings do |settings|
              settings.attribute :welcome_text, type: :text, translated: true
            end

            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :global_menu) do |content_block|
            content_block.cell = "decidim/content_blocks/global_menu"
            content_block.public_name_key = "decidim.content_blocks.global_menu.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :sub_hero) do |content_block|
            content_block.cell = "decidim/content_blocks/sub_hero"
            content_block.public_name_key = "decidim.content_blocks.sub_hero.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :highlighted_content_banner) do |content_block|
            content_block.cell = "decidim/content_blocks/highlighted_content_banner"
            content_block.public_name_key = "decidim.content_blocks.highlighted_content_banner.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :how_to_participate) do |content_block|
            content_block.cell = "decidim/content_blocks/how_to_participate"
            content_block.public_name_key = "decidim.content_blocks.how_to_participate.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :last_activity) do |content_block|
            content_block.cell = "decidim/content_blocks/last_activity"
            content_block.public_name_key = "decidim.content_blocks.last_activity.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :stats) do |content_block|
            content_block.cell = "decidim/content_blocks/stats"
            content_block.public_name_key = "decidim.content_blocks.stats.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :footer_sub_hero) do |content_block|
            content_block.cell = "decidim/content_blocks/footer_sub_hero"
            content_block.public_name_key = "decidim.content_blocks.footer_sub_hero.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :html) do |content_block|
            content_block.cell = "decidim/content_blocks/html"
            content_block.public_name_key = "decidim.content_blocks.html.name"
            content_block.settings_form_cell = "decidim/content_blocks/html_settings_form"

            content_block.settings do |settings|
              settings.attribute :html_content, type: :text, translated: true
            end
          end
        end

        def self.register_static_page_blocks!
          Decidim.content_blocks.register(:static_page, :summary) do |content_block|
            content_block.cell = "decidim/content_blocks/static_page/summary"
            content_block.settings_form_cell = "decidim/content_blocks/static_page/summary_settings_form"
            content_block.public_name_key = "decidim.content_blocks.static_page.summary.name"

            content_block.settings do |settings|
              settings.attribute :summary, type: :text, translated: true
            end

            content_block.default!
          end

          Decidim.content_blocks.register(:static_page, :section) do |content_block|
            content_block.cell = "decidim/content_blocks/static_page/section"
            content_block.settings_form_cell = "decidim/content_blocks/static_page/section_settings_form"
            content_block.public_name_key = "decidim.content_blocks.static_page.section.name"

            content_block.settings do |settings|
              settings.attribute :content, type: :text, translated: true
            end

            content_block.default!
          end

          Decidim.content_blocks.register(:static_page, :two_pane_section) do |content_block|
            content_block.cell = "decidim/content_blocks/static_page/two_pane_section"
            content_block.settings_form_cell = "decidim/content_blocks/static_page/two_pane_section_settings_form"
            content_block.public_name_key = "decidim.content_blocks.static_page.two_pane_section.name"

            content_block.settings do |settings|
              settings.attribute :left_column, type: :text, translated: true
              settings.attribute :right_column, type: :text, translated: true
            end

            content_block.default!
          end
        end

        def self.register_newsletter_templates!
          Decidim.content_blocks.register(:newsletter_template, :basic_only_text) do |content_block|
            content_block.cell = "decidim/newsletter_templates/basic_only_text"
            content_block.settings_form_cell = "decidim/newsletter_templates/basic_only_text_settings_form"
            content_block.public_name_key = "decidim.newsletter_templates.basic_only_text.name"

            content_block.settings do |settings|
              settings.attribute(
                :body,
                type: :text,
                translated: true,
                preview: -> { I18n.t("decidim.newsletter_templates.basic_only_text.body_preview") }
              )
            end

            content_block.default!
          end

          Decidim.content_blocks.register(:newsletter_template, :image_text_cta) do |content_block|
            content_block.cell = "decidim/newsletter_templates/image_text_cta"
            content_block.settings_form_cell = "decidim/newsletter_templates/image_text_cta_settings_form"
            content_block.public_name_key = "decidim.newsletter_templates.image_text_cta.name"

            content_block.images = [
              {
                name: :main_image,
                uploader: "Decidim::NewsletterTemplateImageUploader",
                preview: -> { ActionController::Base.helpers.asset_pack_path("media/images/placeholder.jpg") }
              }
            ]

            content_block.settings do |settings|
              settings.attribute(
                :introduction,
                type: :text,
                translated: true,
                preview: -> { I18n.t("decidim.newsletter_templates.image_text_cta.introduction_preview") }
              )
              settings.attribute(
                :body,
                type: :text,
                translated: true,
                preview: -> { I18n.t("decidim.newsletter_templates.image_text_cta.body_preview") }
              )
              settings.attribute(
                :cta_text,
                type: :text,
                translated: true,
                preview: -> { I18n.t("decidim.newsletter_templates.image_text_cta.cta_text_preview") }
              )
              settings.attribute(
                :cta_url,
                type: :text,
                translated: true,
                preview: -> { "http://decidim.org" }
              )
            end

            content_block.default!
          end
        end
      end
    end
  end
end
