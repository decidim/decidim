# frozen_string_literal: true

module Decidim
  module Elections
    autoload :ElectionResultType, "decidim/api/election_result_type"
    autoload :ElectionAnswerType, "decidim/api/election_answer_type"
    autoload :ElectionQuestionType, "decidim/api/election_question_type"
    autoload :ElectionType, "decidim/api/election_type"
    autoload :ElectionsType, "decidim/api/elections_type"
    autoload :TrusteeType, "decidim/api/trustee_type"
    autoload :BulletinBoardClosureType, "decidim/api/bulletin_board_closure_type"
  end
end
