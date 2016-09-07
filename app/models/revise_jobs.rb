class ReviseJobs
  def call(entries)
    entries.select { |n| n[:tag]=='job' }.map do |entry|
      given_entry_title = entry[:title]

      result_entry = {
        entry_title: given_entry_title,
        divergences: []
      }

      status, response = begin
        [:ok, Mechanize.new.get(entry[:url]).body]
      rescue Exception => e
        [:error, [e.class, e.message].join(': ')]
      end

      if status == :ok
        job_page_content = response
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
      elsif status == :error
        result_entry[:divergences] << {
          reason: 'connection_error',
          details: {
            error_message: response
          }
        }
      end

      result_entry
    end
  end
end

