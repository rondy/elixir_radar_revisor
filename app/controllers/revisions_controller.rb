class RevisionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    entries = params.permit(entriesList: [:title, :url, :subtitle, :tag]).fetch(:entriesList)

    @blog_posts_revision_result = revise_blog_posts(entries)
    @jobs_revision_result = revise_jobs(entries)
    @events_revision_result = revise_events(entries)

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  private

  def revise_blog_posts(entries)
    ReviseBlogPosts.new.call(entries)
  end

  def revise_jobs(entries)
    ReviseJobs.new.call(entries)
  end

  def revise_events(entries)
    ReviseEvents.new.call(entries)
  end
end
