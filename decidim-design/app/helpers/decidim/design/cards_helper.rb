# frozen_string_literal: true

module Decidim
  module Design
    module CardsHelper
      # rubocop:disable Layout/LineLength
      def cards_sections
        [
          {
            id: "types",
            contents: [
              {
                values: section_subtitle(title: "Card L", label: "list")
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l"
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l"
              },
              {
                values: section_subtitle(title: "Card G", label: "grid")
              },
              {
                type: :partial,
                layout: "decidim/design/shared/card_grid",
                template: ["decidim/design/components/cards/static-card-g", "decidim/design/components/cards/static-card-g"]
              },
              {
                values: section_subtitle(title: "Card S", label: "search")
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-s"
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-s"
              }
            ]
          },
          {
            id: "variations",
            contents: [
              {
                type: :text,
                values: ["Each card will look like different regarding the properties of the resource displayed. You can override such behaviour in the specific cell."]
              },
              {
                values: section_subtitle(title: "Metadata items")
              },
              {
                type: :partial,
                layout: "decidim/design/shared/card_grid",
                template: ["decidim/design/components/cards/static-card-g-metadata", "decidim/design/components/cards/static-card-g-metadata-2"]
              },
              {
                type: :text,
                values: ["Each resource define its own metadata items"]
              },
              {
                values: section_subtitle(title: "Highlight")
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-g-highlight"
              },
              {
                type: :text,
                values: ["Used by resources who allow to highlight"]
              },
              {
                values: section_subtitle(title: "Image and description")
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l-image"
              },
              {
                type: :text,
                values: ["Used by <i>Blogs</i> cards"]
              },
              {
                values: section_subtitle(title: "Description")
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l-description"
              },
              {
                type: :text,
                values: ["Used by <i>Debates</i> cards"]
              },
              {
                values: section_subtitle(title: "Use different template for the image block")
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l-meetings"
              },
              {
                type: :text,
                values: ["Used by <i>Meetings</i> cards"]
              },
              {
                values: section_subtitle(title: "Use the extra_data block")
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l-extra-data"
              },
              {
                type: :text,
                values: ["Used by <i>Accountability projects</i> cards. This card requires the module assets to display properly, i.e. <code>append_stylesheet_pack_tag \"decidim_accountability\"</code>"]
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l-extra-data-2"
              },
              {
                type: :text,
                values: ["Used by <i>Budget projects</i> cards. This card requires the module assets to display properly, i.e. <code>append_stylesheet_pack_tag \"decidim_budgets\"</code>"]
              }
            ]
          },
          {
            id: "sourcecode",
            contents: [
              {
                type: :table,
                options: { headings: %w(Card Code Usage) },
                items: cards_table(
                  { name: "Card L (core)", url: "https://github.com/decidim/decidim/tree/develop/decidim-core/app/cells/decidim/card_l_cell.rb", usage: "--" },
                  { name: "Card G (core)", url: "https://github.com/decidim/decidim/tree/develop/decidim-core/app/cells/decidim/card_g_cell.rb", usage: "--" },
                  { name: "Card S (core)", url: "https://github.com/decidim/decidim/tree/develop/decidim-core/app/cells/decidim/card_s_cell.rb", usage: "--" },
                  { name: "Result L", url: "https://github.com/decidim/decidim/blob/develop/decidim-accountability/app/cells/decidim/accountability/result_l_cell.rb",
                    usage: "https://github.com/decidim/decidim/blob/develop/decidim-accountability/app/cells/decidim/accountability/results/show.erb#L3" },
                  { name: "Post L", url: "https://github.com/decidim/decidim/blob/develop/decidim-blogs/app/cells/decidim/blogs/post_l_cell.rb",
                    usage: "https://github.com/decidim/decidim/blob/develop/decidim-blogs/app/views/decidim/blogs/posts/index.html.erb#L16" },
                  { name: "Project L", url: "https://github.com/decidim/decidim/blob/develop/decidim-budgets/app/cells/decidim/budgets/project_l_cell.rb",
                    usage: "https://github.com/decidim/decidim/blob/develop/decidim-budgets/app/views/decidim/budgets/projects/_project.html.erb#L2" },
                  { name: "Debate L", url: "https://github.com/decidim/decidim/blob/develop/decidim-debates/app/cells/decidim/debates/debate_l_cell.rb",
                    usage: "https://github.com/decidim/decidim/blob/develop/decidim-debates/app/views/decidim/debates/debates/_debates.html.erb#L6" },
                  { name: "Meeting L", url: "https://github.com/decidim/decidim/blob/develop/decidim-meetings/app/cells/decidim/meetings/meeting_l_cell.rb",
                    usage: "https://github.com/decidim/decidim/blob/develop/decidim-meetings/app/views/decidim/meetings/shared/_meetings.html.erb#L20" },
                  { name: "Collaborative Draft L",
                    url: "https://github.com/decidim/decidim/blob/develop/decidim-proposals/app/cells/decidim/proposals/collaborative_draft_l_cell.rb", usage: "https://github.com/decidim/decidim/blob/develop/decidim-proposals/app/views/decidim/proposals/collaborative_drafts/_collaborative_drafts.html.erb#L10" },
                  { name: "Proposal L", url: "https://github.com/decidim/decidim/blob/develop/decidim-proposals/app/cells/decidim/proposals/proposal_l_cell.rb",
                    usage: "https://github.com/decidim/decidim/blob/develop/decidim-proposals/app/views/decidim/proposals/proposals/_proposals.html.erb#L15" },
                  { name: "Sortition L", url: "https://github.com/decidim/decidim/blob/develop/decidim-sortitions/app/cells/decidim/sortitions/sortition_l_cell.rb",
                    usage: "https://github.com/decidim/decidim/blob/develop/decidim-sortitions/app/views/decidim/sortitions/sortitions/_sortitions.html.erb#L6" },
                  { name: "Assembly G", url: "https://github.com/decidim/decidim/blob/develop/decidim-assemblies/app/cells/decidim/assemblies/assembly_g_cell.rb",
                    usage: "https://github.com/decidim/decidim/blob/develop/decidim-assemblies/app/views/decidim/assemblies/assemblies/_collection.html.erb#L4" },
                  { name: "Post G", url: "https://github.com/decidim/decidim/blob/develop/decidim-blogs/app/cells/decidim/blogs/post_g_cell.rb",
                    usage: "https://github.com/decidim/decidim/blob/develop/decidim-blogs/app/cells/decidim/blogs/content_blocks/highlighted_posts/content.erb#L15" },
                  { name: "Conference G", url: "https://github.com/decidim/decidim/blob/develop/decidim-conferences/app/cells/decidim/conferences/conference_g_cell.rb",
                    usage: "https://github.com/decidim/decidim/blob/develop/decidim-conferences/app/views/decidim/conferences/conferences/index.html.erb#L30" },
                  { name: "Election G", url: "https://github.com/decidim/decidim/blob/develop/decidim-elections/app/cells/decidim/elections/election_g_cell.rb",
                    usage: "https://github.com/decidim/decidim/blob/develop/decidim-elections/app/views/decidim/elections/elections/_elections.html.erb#L13" },
                  { name: "Voting G", url: "https://github.com/decidim/decidim/blob/develop/decidim-elections/app/cells/decidim/votings/voting_g_cell.rb",
                    usage: "https://github.com/decidim/decidim/blob/develop/decidim-elections/app/views/decidim/votings/votings/_votings.html.erb#L14" },
                  { name: "Initiative G", url: "https://github.com/decidim/decidim/blob/develop/decidim-initiatives/app/cells/decidim/initiatives/initiative_g_cell.rb",
                    usage: "https://github.com/decidim/decidim/blob/develop/decidim-initiatives/app/views/decidim/initiatives/initiatives/_initiatives.html.erb#L12" },
                  { name: "Process G",
                    url: "https://github.com/decidim/decidim/blob/develop/decidim-participatory_processes/app/cells/decidim/participatory_processes/process_g_cell.rb", usage: "https://github.com/decidim/decidim/blob/develop/decidim-participatory_processes/app/views/decidim/participatory_processes/participatory_processes/_collection.html.erb#L5" },
                  { name: "Process Group G",
                    url: "https://github.com/decidim/decidim/blob/develop/decidim-participatory_processes/app/cells/decidim/participatory_processes/process_group_g_cell.rb", usage: "https://github.com/decidim/decidim/blob/develop/decidim-participatory_processes/app/views/decidim/participatory_process_groups/_participatory_process_group.html.erb#L1" },
                  { name: "Proposal G", url: "https://github.com/decidim/decidim/blob/develop/decidim-proposals/app/cells/decidim/proposals/proposal_g_cell.rb",
                    usage: "https://github.com/decidim/decidim/blob/develop/decidim-proposals/app/views/decidim/proposals/proposals/_proposals.html.erb#L15" }
                )
              }
            ]
          }
        ]
      end
      # rubocop:enable Layout/LineLength

      def cards_table(*table_rows, **_opts)
        table_rows.map do |table_cell|
          [
            table_cell[:name],
            link_to(table_cell[:url].split("/").last, table_cell[:url], target: "_blank", class: "text-secondary underline", rel: "noopener"),
            if table_cell[:usage].to_s.start_with?("http")
              link_to(table_cell[:usage].split("/").last, table_cell[:usage], target: "_blank", class: "text-secondary underline", rel: "noopener")
            else
              table_cell[:usage]
            end
          ]
        end
      end
    end
  end
end
