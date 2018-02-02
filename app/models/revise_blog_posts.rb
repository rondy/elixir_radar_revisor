class ReviseBlogPosts
  def call(entries)
    Parallel.map(filtered_entries(entries), in_processes: 8) do |entry|
      revise_entry(entry)
    end
  end

  private

  def filtered_entries(entries)
    entries.select { |entry| entry[:tag] == 'blog-post' }
  end

  def revise_entry(entry)
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
        revise_from_successful_response(entry, result_entry, fetched_page_title)
      end,

      on_error: lambda do |error_message|
        revise_from_failed_response(entry, result_entry, error_message)
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

  def revise_from_successful_response(entry, result_entry, fetched_page_title)
    given_entry_title = entry[:title]

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

    given_domain = entry[:subtitle]
    fetched_domain = parse_domain_from_entry_url(entry[:url])

    domain_matches = (given_domain == fetched_domain)

    unless domain_matches
      result_entry[:divergences] << {
        reason: 'domain_does_not_match',
        details: {
          given_domain: given_domain,
          fetched_domain: fetched_domain
        }
      }
    end

    result_entry
  end

  def revise_from_failed_response(_, result_entry, error_message)
    result_entry[:divergences] << {
      reason: 'connection_error',
      details: {
        error_message: error_message
      }
    }

    result_entry
  end

  def fetch_page_title(entry)
    agent = Mechanize.new
    agent.read_timeout = 2

    page = agent.get(entry[:url])

    page.title || extract_title_from_og_title(page)
  end

  def extract_title_from_og_title(page)
    page
      .search('meta[property="og:title"]')
      .first
      .try(:[], 'content')
  end

  def check_titles_match(given_title, fetched_title)
    CheckTitlesMatch.new.call(given_title, fetched_title)
  end

  def parse_domain_from_entry_url(entry_url)
    ParseBlogPostDomain.new.call(entry_url)
  end
end
