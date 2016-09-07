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

    fetching_content_from_web_page(
      action: lambda do
        fetch_meetup_com_event_title(entry)
      end,

      on_success: lambda do |fetched_event_title|
        given_event_title = entry[:subtitle]

        event_title_matches = check_titles_match(given_event_title, fetched_event_title)

        unless event_title_matches
          result_entry[:divergences] << {
            reason: 'event_title_does_not_match',
            details: {
              given_event_title: given_event_title,
              fetched_event_title: fetched_event_title
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

  def revise_event_from_generic_source(entry)
    given_entry_title = entry[:title]

    result_entry = {
      entry_title: given_entry_title,
      divergences: []
    }

    fetching_content_from_web_page(
      action: lambda do
        fetch_page_title(entry)
      end,

      on_success: lambda do |fetched_page_title|
        page_title_matches = check_titles_match(given_entry_title, fetched_page_title)

        unless page_title_matches
          result_entry[:divergences] << {
            reason: 'page_title_does_not_match',
            details: {
              fetched_page_title: fetched_page_title
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

  def fetching_content_from_web_page(action:, on_success:, on_error:)
    FetchContentFromWebPage.new.call(
      action: action,
      on_success: on_success,
      on_error: on_error
    )
  end

  def fetch_page_title(entry)
    Mechanize.new.get(entry[:url]).title
  end

  def fetch_meetup_com_event_title(entry)
    Mechanize.new.get(entry[:url]).search('#event-title h1').text.strip
  end

  def check_titles_match(given_title, fetched_title)
    CheckTitlesMatch.new.call(given_title, fetched_title)
  end
end
