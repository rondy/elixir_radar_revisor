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
        fetch_meetup_com_event_description(entry)
      end,

      on_success: lambda do |fetched_event_description|
        given_event_description = entry[:description]

        event_description_matches = check_descriptions_match(given_event_description, fetched_event_description)

        unless event_description_matches
          result_entry[:divergences] << {
            reason: 'event_description_does_not_match',
            details: {
              given_event_description: given_event_description,
              fetched_event_description: fetched_event_description
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

    agent.get(entry[:url]).search('div.pageHead--titleArea h1').text.strip
  end

  def fetch_meetup_com_event_date(entry)
    agent = Mechanize.new
    agent.read_timeout = 2

    page = agent.get(entry[:url])

    span_date = page.search('div.eventTimeDisplay span.eventTimeDisplay-startDate span').first
    event_date_text = span_date.text

    event_date_text.to_s.strip
  end

  def fetch_meetup_com_event_description(entry)
    event_date = fetch_meetup_com_event_date(entry)
    event_location = fetch_meetup_com_event_location(entry)

    return event_date if event_location.blank?

    "#{event_date} - #{event_location}"
  end

  def fetch_meetup_com_event_location(entry)
    agent = Mechanize.new
    agent.read_timeout = 2

    page = agent.get(entry[:url])

    json_info = page.search('script[type="application/ld+json"]').first
    parsed_info = JSON.parse(json_info, symbolize_names: true)

    location_info = parsed_info[:location]
    return nil if location_info.blank?

    address = location_info[:address]
    composed_location = [address[:addressLocality], address[:addressRegion], address[:addressCountry]]
    filtered_location = composed_location.reject(&:blank?)

    filtered_location.join(', ')
  end

  def check_titles_match(given_title, fetched_title)
    CheckTitlesMatch.new.call(given_title, fetched_title)
  end

  def standardize_event_description(description)
    date, location = description.split(' - ')
    "#{parse_event_date(date)} - #{location}"
  end

  def check_descriptions_match(given_event_description, fetched_event_description)
    standardize_event_description(given_event_description) == standardize_event_description(fetched_event_description)
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
