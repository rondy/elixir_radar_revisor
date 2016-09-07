class ReviseBlogPosts
  def call(entries)
    entries.select { |entry| entry[:tag] == 'blog-post' }.map do |entry|
      given_entry_title = entry[:title]

      result_entry = {
        entry_title: given_entry_title,
        divergences: []
      }

      status, response = begin
        [:ok, fetch_page_title(entry)]
      rescue Exception => e
        [:error, [e.class, e.message].join(': ')]
      end

      if status == :ok
        fetched_page_title = response
        page_title_matches = check_titles_match(given_entry_title, fetched_page_title)

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

  private

  def fetch_page_title(entry)
    page = Mechanize.new.get(entry[:url])
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
end
