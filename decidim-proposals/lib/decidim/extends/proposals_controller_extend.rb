module ProposalsControllerExtend
 def index
    @proposals = search
                  .results
                  .not_hidden
                  .authorized
                  .includes(:author)
                  .includes(:category)
                  .includes(:scope)

    @voted_proposals = if current_user
                         ProposalVote.where(
                           author: current_user,
                           proposal: @proposals.pluck(:id)
                         ).pluck(:decidim_proposal_id)
                       else
                         []
                       end

    @proposals = paginate(@proposals)
    @proposals = reorder(@proposals)
  end
end

Decidim::Proposals::ProposalsController.class_eval do
  prepend(ProposalsControllerExtend)
end
