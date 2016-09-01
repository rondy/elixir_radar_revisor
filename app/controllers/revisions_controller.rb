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
    entries.select { |n| n[:tag]=='blog-post' }.map do |entry|
      given_entry_title = entry[:title]

      result_entry = {
        entry_title: given_entry_title,
        divergences: []
      }

      fetched_page_title = Mechanize.new.get(entry[:url]).title
      page_title_matches = !!(fetched_page_title =~ Regexp.new(given_entry_title))

      unless page_title_matches
        result_entry[:divergences] << {
          reason: 'page_title_does_not_match',
          details: {
            fetched_page_title: fetched_page_title
          }
        }
      end

      result_entry
    end
  end

  def revise_jobs(entries)
    entries.select { |n| n[:tag]=='job' }.map do |entry|
      given_entry_title = entry[:title]

      result_entry = {
        entry_title: given_entry_title,
        divergences: []
      }

      job_entry_details = entry[:subtitle].split('-').first.strip
      job_details_matches = !!(Mechanize.new.get(entry[:url]).body =~ Regexp.new(Regexp.escape(job_entry_details)))

      unless job_details_matches
        result_entry[:divergences] << {
          reason: 'job_details_does_not_match',
          details: {
            given_job_details: job_entry_details
          }
        }
      end

      result_entry
    end
  end

  def revise_events(entries)
    entries.select { |n| n[:tag]=='event' }.map do |entry|
      given_entry_title = entry[:title]

      result_entry = {
        entry_title: given_entry_title,
        divergences: []
      }

      fetched_page_title = Mechanize.new.get(entry[:url]).title
      page_title_matches = !!(fetched_page_title =~ Regexp.new(given_entry_title))

      unless page_title_matches
        result_entry[:divergences] << {
          reason: 'page_title_does_not_match',
          details: {
            fetched_page_title: fetched_page_title
          }
        }
      end

      result_entry
    end
  end
end
