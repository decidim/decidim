# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class RegistryManager
        def self.register!
          Decidim.content_blocks.register(:homepage, :highlighted_processes) do |content_block|
            content_block.cell = "decidim/participatory_processes/content_blocks/highlighted_processes"
            content_block.public_name_key = "decidim.participatory_processes.content_blocks.highlighted_processes.name"
            content_block.settings_form_cell = "decidim/participatory_processes/content_blocks/highlighted_processes_settings_form"

            content_block.settings do |settings|
              settings.attribute :max_results, type: :integer, default: 6
            end
          end

          Decidim.content_blocks.register(:participatory_process_group_homepage, :title) do |content_block|
            content_block.cell = "decidim/participatory_process_groups/content_blocks/main_data"
            content_block.public_name_key = "decidim.participatory_process_groups.content_blocks.main_data.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:participatory_process_group_homepage, :extra_data) do |content_block|
            content_block.cell = "decidim/participatory_process_groups/content_blocks/extra_data"
            content_block.public_name_key = "decidim.participatory_process_groups.content_blocks.extra_data.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:participatory_process_group_homepage, :hero) do |content_block|
            content_block.cell = "decidim/content_blocks/participatory_space_hero"
            content_block.settings_form_cell = "decidim/content_blocks/participatory_space_hero_settings_form"
            content_block.public_name_key = "decidim.participatory_processes.content_blocks.hero.name"

            content_block.images = [
              {
                name: :background_image,
                uploader: "Decidim::BackgroundImageUploader"
              }
            ]

            content_block.settings do |settings|
              settings.attribute :button_text, type: :text, translated: true
              settings.attribute :button_url, type: :text, translated: true
            end

            content_block.default!
          end

          (1..3).each do |index|
            Decidim.content_blocks.register(:participatory_process_group_homepage, :"html_#{index}") do |content_block|
              content_block.cell = "decidim/content_blocks/html"
              content_block.public_name_key = "decidim.participatory_process_groups.content_blocks.html_#{index}.name"
              content_block.settings_form_cell = "decidim/content_blocks/html_settings_form"

              content_block.settings do |settings|
                settings.attribute :html_content, type: :text, translated: true
              end
            end
          end

          Decidim.content_blocks.register(:participatory_process_homepage, :html) do |content_block|
            content_block.cell = "decidim/content_blocks/html"
            content_block.public_name_key = "decidim.content_blocks.html.name"
            content_block.settings_form_cell = "decidim/content_blocks/html_settings_form"

            content_block.settings do |settings|
              settings.attribute :html_content, type: :text, translated: true
            end
          end

          Decidim.content_blocks.register(:participatory_process_homepage, :hero) do |content_block|
            content_block.cell = "decidim/content_blocks/participatory_space_hero"
            content_block.settings_form_cell = "decidim/content_blocks/participatory_space_hero_settings_form"
            content_block.public_name_key = "decidim.participatory_processes.content_blocks.hero.name"

            content_block.images = [
              {
                name: :background_image,
                uploader: "Decidim::BackgroundImageUploader"
              }
            ]

            content_block.settings do |settings|
              settings.attribute :button_text, type: :text, translated: true
              settings.attribute :button_url, type: :text, translated: true
            end

            content_block.default!
          end

          Decidim.content_blocks.register(:participatory_process_homepage, :announcement) do |content_block|
            content_block.cell = "decidim/content_blocks/participatory_space_announcement"
            content_block.public_name_key = "decidim.content_blocks.announcement.name"
          end

          Decidim.content_blocks.register(:participatory_process_homepage, :main_data) do |content_block|
            content_block.cell = "decidim/participatory_processes/content_blocks/main_data"
            content_block.public_name_key = "decidim.content_blocks.main_data.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:participatory_process_homepage, :extra_data) do |content_block|
            content_block.cell = "decidim/participatory_processes/content_blocks/extra_data"
            content_block.public_name_key = "decidim.participatory_processes.content_blocks.extra_data.name"
          end

          Decidim.content_blocks.register(:participatory_process_homepage, :metadata) do |content_block|
            content_block.cell = "decidim/participatory_processes/content_blocks/metadata"
            content_block.public_name_key = "decidim.content_blocks.metadata.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:participatory_process_homepage, :last_activity) do |content_block|
            content_block.cell = "decidim/content_blocks/participatory_space_last_activity"
            content_block.public_name_key = "decidim.content_blocks.last_activity.name"
            content_block.settings_form_cell = "decidim/content_blocks/last_activity_settings_form"
            content_block.settings do |settings|
              settings.attribute :max_last_activity_users, type: :integer, default: Decidim.default_max_last_activity_users
            end
          end

          Decidim.content_blocks.register(:participatory_process_homepage, :stats) do |content_block|
            content_block.cell = "decidim/participatory_processes/content_blocks/stats"
            content_block.public_name_key = "decidim.content_blocks.participatory_space_stats.name"
          end

          Decidim.content_blocks.register(:participatory_process_homepage, :related_processes) do |content_block|
            content_block.cell = "decidim/participatory_processes/content_blocks/related_processes"
            content_block.settings_form_cell = "decidim/participatory_processes/content_blocks/highlighted_processes_settings_form"
            content_block.public_name_key = "decidim.participatory_processes.content_blocks.related_processes.name"

            content_block.settings do |settings|
              settings.attribute :max_results, type: :integer, default: 6
            end
          end

          Decidim.content_blocks.register(:participatory_process_homepage, :related_documents) do |content_block|
            content_block.cell = "decidim/content_blocks/participatory_space_documents"
            content_block.public_name_key = "decidim.application.documents.related_documents"
          end

          Decidim.content_blocks.register(:participatory_process_homepage, :related_images) do |content_block|
            content_block.cell = "decidim/content_blocks/participatory_space_images"
            content_block.public_name_key = "decidim.application.photos.related_photos"
          end

          Decidim.content_blocks.register(:participatory_process_group_homepage, :stats) do |content_block|
            content_block.cell = "decidim/participatory_process_groups/content_blocks/statistics"
            content_block.public_name_key = "decidim.participatory_process_groups.content_blocks.stats.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:participatory_process_group_homepage, :participatory_processes) do |content_block|
            content_block.cell = "decidim/participatory_process_groups/content_blocks/related_processes"
            content_block.settings_form_cell = "decidim/participatory_processes/content_blocks/processes_settings_form"
            content_block.public_name_key = "decidim.participatory_process_groups.content_blocks.participatory_processes.name"

            content_block.settings do |settings|
              settings.attribute :default_filter, type: :enum, default: "active", choices: %w(active all)
            end
          end

          register_highlighted_debates
          register_highlighted_meetings
          register_highlighted_posts
          register_highlighted_proposals
          register_highlighted_results
          register_related_assemblies
        end

        def self.register_highlighted_debates
          return unless Decidim.module_installed?(:debates)

          Decidim.content_blocks.register(:participatory_process_homepage, :highlighted_debates) do |content_block|
            content_block.cell = "decidim/debates/content_blocks/highlighted_debates"
            content_block.public_name_key = "decidim.debates.content_blocks.highlighted_debates.name"
            content_block.component_manifest_name = "debates"
          end
        end

        def self.register_highlighted_meetings
          return unless Decidim.module_installed?(:meetings)

          Decidim.content_blocks.register(:participatory_process_homepage, :highlighted_meetings) do |content_block|
            content_block.cell = "decidim/meetings/content_blocks/highlighted_meetings"
            content_block.settings_form_cell = "decidim/content_blocks/highlighted_elements_for_component_settings_form"
            content_block.public_name_key = "decidim.meetings.content_blocks.upcoming_meetings.name"
            content_block.component_manifest_name = "meetings"

            content_block.settings do |settings|
              settings.attribute :component_id, type: :select, default: nil
            end
          end

          Decidim.content_blocks.register(:participatory_process_group_homepage, :highlighted_meetings) do |content_block|
            content_block.cell = "decidim/meetings/content_blocks/highlighted_meetings"
            content_block.settings_form_cell = "decidim/content_blocks/highlighted_elements_settings_form"
            content_block.public_name_key = "decidim.meetings.content_blocks.upcoming_meetings.name"
            content_block.component_manifest_name = "meetings"
            content_block.default!

            content_block.settings do |settings|
              settings.attribute :order, type: :enum, default: "random", choices: %w(random recent)
              settings.attribute :show_space, type: :boolean, default: true
            end
          end
        end

        def self.register_highlighted_posts
          return unless Decidim.module_installed?(:blogs)

          Decidim.content_blocks.register(:participatory_process_homepage, :highlighted_posts) do |content_block|
            content_block.cell = "decidim/blogs/content_blocks/highlighted_posts"
            content_block.settings_form_cell = "decidim/content_blocks/highlighted_elements_for_component_settings_form"
            content_block.public_name_key = "decidim.blogs.content_blocks.highlighted_posts.name"
            content_block.component_manifest_name = "blogs"

            content_block.settings do |settings|
              settings.attribute :component_id, type: :select, default: nil
            end
          end
        end

        def self.register_highlighted_proposals
          return unless Decidim.module_installed?(:proposals)

          Decidim.content_blocks.register(:participatory_process_homepage, :highlighted_proposals) do |content_block|
            content_block.cell = "decidim/proposals/content_blocks/highlighted_proposals"
            content_block.settings_form_cell = "decidim/content_blocks/highlighted_elements_for_component_settings_form"
            content_block.public_name_key = "decidim.proposals.content_blocks.highlighted_proposals.name"
            content_block.component_manifest_name = "proposals"

            content_block.settings do |settings|
              settings.attribute :order, type: :enum, default: "recent", choices: %w(random recent)
              settings.attribute :component_id, type: :select, default: nil
            end
          end

          Decidim.content_blocks.register(:participatory_process_group_homepage, :highlighted_proposals) do |content_block|
            content_block.cell = "decidim/proposals/content_blocks/highlighted_proposals"
            content_block.settings_form_cell = "decidim/content_blocks/highlighted_elements_settings_form"
            content_block.public_name_key = "decidim.proposals.content_blocks.highlighted_proposals.name"
            content_block.component_manifest_name = "proposals"

            content_block.settings do |settings|
              settings.attribute :order, type: :enum, default: "random", choices: %w(random recent)
              settings.attribute :show_space, type: :boolean, default: true
            end
          end
        end

        def self.register_highlighted_results
          return unless Decidim.module_installed?(:accountability)

          Decidim.content_blocks.register(:participatory_process_homepage, :highlighted_results) do |content_block|
            content_block.cell = "decidim/accountability/content_blocks/highlighted_results"
            content_block.settings_form_cell = "decidim/content_blocks/highlighted_elements_for_component_settings_form"
            content_block.public_name_key = "decidim.accountability.content_blocks.highlighted_results.results"
            content_block.component_manifest_name = "accountability"

            content_block.settings do |settings|
              settings.attribute :order, type: :enum, default: "random", choices: %w(random recent)
              settings.attribute :component_id, type: :select, default: nil
            end
          end

          Decidim.content_blocks.register(:participatory_process_group_homepage, :highlighted_results) do |content_block|
            content_block.cell = "decidim/accountability/content_blocks/highlighted_results"
            content_block.settings_form_cell = "decidim/content_blocks/highlighted_elements_settings_form"
            content_block.public_name_key = "decidim.accountability.content_blocks.highlighted_results.results"
            content_block.component_manifest_name = "accountability"
            content_block.default!

            content_block.settings do |settings|
              settings.attribute :order, type: :enum, default: "random", choices: %w(random recent)
              settings.attribute :show_space, type: :boolean, default: true
            end
          end
        end

        def self.register_related_assemblies
          return unless Decidim.module_installed?(:assemblies)

          Decidim.content_blocks.register(:participatory_process_homepage, :related_assemblies) do |content_block|
            content_block.cell = "decidim/assemblies/content_blocks/related_assemblies"
            content_block.settings_form_cell = "decidim/assemblies/content_blocks/highlighted_assemblies_settings_form"
            content_block.public_name_key = "decidim.assemblies.content_blocks.related_assemblies.name"

            content_block.settings do |settings|
              settings.attribute :max_results, type: :integer, default: 6
            end
          end
        end
      end
    end
  end
end
