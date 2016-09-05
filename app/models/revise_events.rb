class ReviseEvents
  def call(entries)
    entries.select { |n| n[:tag]=='event' }.map do |entry|
      if entry[:url] =~ /meetup\.com/
        revise_event_from_meetup_com(entry)
      else
        revise_event_from_generic_source(entry)
      end
    end
  end

  private

  def revise_event_from_meetup_com(entry)
    given_entry_title = entry[:title]

    result_entry = {
      entry_title: given_entry_title,
      divergences: []
    }

    given_event_title = entry[:subtitle]
    fetched_event_title = Mechanize.new.get(entry[:url]).search('#event-title h1').text.strip

    event_title_matches = !!(fetched_event_title =~ Regexp.new(Regexp.escape(given_event_title)))

    unless event_title_matches
      result_entry[:divergences] << {
        reason: 'event_title_does_not_match',
        details: {
          given_event_title: given_event_title,
          fetched_event_title: fetched_event_title
        }
      }
    end

    result_entry
  end

  def revise_event_from_generic_source(entry)
    given_entry_title = entry[:title]

    result_entry = {
      entry_title: given_entry_title,
      divergences: []
    }

    status, response = begin
      [:ok, Mechanize.new.get(entry[:url]).title]
    rescue Exception => e
      [:error, [e.class, e.message].join(': ')]
    end

    if status == :ok
      fetched_page_title = response
      page_title_matches = !!(fetched_page_title =~ Regexp.new(given_entry_title))

      unless page_title_matches
        result_entry[:divergences] << {
          reason: 'page_title_does_not_match',
          details: {
            fetched_page_title: fetched_page_title
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
