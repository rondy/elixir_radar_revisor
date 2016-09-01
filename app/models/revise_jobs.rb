class ReviseJobs
  def call(entries)
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
end
