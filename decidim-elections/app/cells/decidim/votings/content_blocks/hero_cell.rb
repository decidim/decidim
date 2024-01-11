# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      class HeroCell < Decidim::ContentBlocks::ParticipatorySpaceHeroCell
        delegate :start_time, :end_time, to: :resource

        def has_hashtag?
          false
        end

        def subtitle_text
          "#{start_text} — #{end_text}"
        end

        private

        def start_text
          content_tag :span, title: t("activemodel.attributes.voting.start_time") do
            format_date(start_time)
          end
        end

        def end_text
          content_tag :span, title: t("activemodel.attributes.voting.end_time") do
            format_date(end_time)
          end
        end

        def format_date(time)
          if time
            l(time.to_date, format: :decidim_short)
          else
            t("decidim.votings.votings_m.unspecified")
          end
        end
      end
    end
  end
end
