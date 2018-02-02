class ParseBlogPostDomain
  def call(entry_url)
    if domain_from_medium_com?(entry_url)
      parse_domain_from_medium_com(entry_url)
    else
      parse_domain_from_generic_source(entry_url)
    end
  end

  private

  def domain_from_medium_com?(entry_url)
    extract_host(entry_url) =~ /medium\.com/
  end

  def parse_domain_from_medium_com(entry_url)
    url_host = extract_host(entry_url)
    medium_username = extract_medium_username(entry_url)

    "#{url_host}/#{medium_username}"
  end

  def extract_medium_username(url)
    extract_path(url).split('/')[1]
  end

  def parse_domain_from_generic_source(entry_url)
    extract_host(entry_url).sub(/^www\./, '')
  end

  def extract_host(url)
    URI.parse(url).host
  end

  def extract_path(url)
    URI.parse(url).path
  end
end
