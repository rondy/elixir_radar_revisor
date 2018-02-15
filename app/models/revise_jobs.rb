class ReviseJobs
  def call(entries)
    iterate_over_entries(filtered_entries(entries)) do |entry|
      revise_entry(entry)
    end
  end

  private

  def iterate_over_entries(entries, &block)
    IterateOverEntries.new.call(entries, &block)
  end

  def filtered_entries(entries)
    entries.select { |entry| entry[:tag] == 'job' }
  end

  def revise_entry(entry)
    given_entry_title = entry[:title]

    result_entry = {
      entry_title: given_entry_title,
      divergences: []
    }

    fetching_content_from_web_page(
      action: lambda do
        fetch_job_page_content(entry)
      end,

      on_success: lambda do |job_page_content|
        job_entry_details = entry[:subtitle].split('-').first.strip

        job_details_matches = !!(job_page_content =~ Regexp.new(Regexp.escape(job_entry_details)))

        unless job_details_matches
          result_entry[:divergences] << {
            reason: 'job_details_does_not_match',
            details: {
              given_job_details: job_entry_details
            }
          }
        end
      end,

      on_error: lambda do |error_message|
        result_entry[:divergences] << {
          reason: 'connection_error',
          details: {
            error_message: error_message
          }
        }
      end
    )

    result_entry
  end

  def fetch_job_page_content(entry)
    agent = Mechanize.new
    agent.read_timeout = 2

    agent.get(entry[:url]).body
  end

  def fetching_content_from_web_page(action:, on_success:, on_error:)
    FetchContentFromWebPage.new.call(
      action: action,
      on_success: on_success,
      on_error: on_error
    )
  end
end
