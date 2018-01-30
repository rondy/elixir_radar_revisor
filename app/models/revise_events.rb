class ReviseEvents
  def call(entries)
    filtered_entries(entries).map do |entry|
      revise_entry(entry)
    end
  end

  private

  def filtered_entries(entries)
    entries.select { |entry| entry[:tag] == 'event' }
  end

  def revise_entry(entry)
    if entry[:url] =~ /meetup\.com/
      revise_event_from_meetup_com(entry)
    else
      revise_event_from_generic_source(entry)
    end
  end

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

    fetching_content_from_web_page(
      action: lambda do
        fetch_meetup_com_event_date(entry)
      end,

      on_success: lambda do |fetched_event_date|
        given_event_date = entry[:description]

        event_date_matches = check_dates_match(given_event_date, fetched_event_date)

        unless event_date_matches
          result_entry[:divergences] << {
            reason: 'event_date_does_not_match',
            details: {
              given_event_date: given_event_date,
              fetched_event_date: fetched_event_date
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
              given_page_title: given_entry_title,
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
    agent = Mechanize.new
    agent.read_timeout = 2

    agent.get(entry[:url]).title
  end

  def fetch_meetup_com_event_title(entry)
    agent = Mechanize.new
    agent.read_timeout = 2

    agent.get(entry[:url]).search('#event-title h1').text.strip
  end

  def fetch_meetup_com_event_date(entry)
    agent = Mechanize.new
    agent.read_timeout = 2

    page = agent.get(entry[:url])

    event_date_text =
      page.search('.past-event-info li:first').text.presence ||
      page.search('time[itemprop="startDate"]').text

    event_date_text.to_s.strip
  end

  def check_titles_match(given_title, fetched_title)
    CheckTitlesMatch.new.call(given_title, fetched_title)
  end

  def check_dates_match(given_event_date, fetched_event_date)
    parse_event_date(given_event_date) == parse_event_date(fetched_event_date)
  end

  def parse_event_date(event_date)
    normalized_event_date = normalize_event_date(event_date)

    parse_event_time(normalized_event_date)
      .try(:to_date)
  end

  def normalize_event_date(event_date)
    event_date.to_s.split('·').first.to_s.strip
  end

  def parse_event_time(event_date)
    Time.parse(event_date)
  rescue TypeError, ArgumentError => e
    Chronic.parse(event_date)
  end
end
