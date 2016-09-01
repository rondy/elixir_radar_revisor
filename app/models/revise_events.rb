class ReviseEvents
  def call(entries)
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
