class RevisionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  ACTIONS = {
    revise_blog_posts: lambda { |entries| ReviseBlogPosts.new.call(entries) },
    revise_jobs: lambda { |entries| ReviseJobs.new.call(entries) },
    revise_events: lambda { |entries| ReviseEvents.new.call(entries) }
  }

  def create
    entries = params.permit(entriesList: [:title, :url, :subtitle, :description, :tag]).fetch(:entriesList)

    @blog_posts_revision_result,
    @jobs_revision_result,
    @events_revision_result = fetch_revision_results_from(entries)

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  private

  def fetch_revision_results_from(entries)
    ACTIONS.keys.map do |action|
      ACTIONS.fetch(action).call(entries)
    end
  end
end
