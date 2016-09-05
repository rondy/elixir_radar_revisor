class ReviseBlogPosts
  def call(entries)
    entries.select { |entry| entry[:tag] == 'blog-post' }.map do |entry|
      given_entry_title = entry[:title]

      result_entry = {
        entry_title: given_entry_title,
        divergences: []
      }

      fetched_page_title = fetch_page_title(entry)
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
end
