# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    module ContentBlocks
      class TitleCell < Decidim::ViewModel
        include Decidim::SanitizeHelper
        include Decidim::IconHelper

        delegate :group_url, to: :participatory_process_group

        def participatory_process_group
          @participatory_process_group ||= controller.send(:group)
        end

        def hashtag_text
          @hashtag_text ||= decidim_html_escape(participatory_process_group.hashtag || "")
        end

        def has_hashtag?
          hashtag_text.present?
        end

        def has_group_url?
          group_url.present?
        end

        def meta_scope
          @meta_scope ||= translated_attribute(participatory_process_group.meta_scope)
        end

        def has_meta_scope?
          meta_scope.present?
        end

        def group_url_text
          group_uri.host + group_uri.path
        end

        def decidim_participatory_processes
          Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
        end

        def participatory_processes_count
          @participatory_processes_count ||= participatory_process_group.participatory_processes.count
        end

        private

        def group_uri
          @group_uri = URI.parse(group_url)
        end
      end
    end
  end
end
