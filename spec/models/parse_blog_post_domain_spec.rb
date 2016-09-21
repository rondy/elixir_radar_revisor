require 'rails_helper'

describe ParseBlogPostDomain do
  it 'returns a domain from a generic source url' do
    url_from_generic_source = 'https://dockyard.com/blog/2016/08/09/phoenix-channels-vs-rails-action-cable'
    parsed_domain = ParseBlogPostDomain.new.call(url_from_generic_source)
    expect(parsed_domain).to eq('dockyard.com')

    url_from_generic_source = 'https://dev.bleacherreport.com/elixir-phoenix-centralized-http-logging-aa50efe3105b'
    parsed_domain = ParseBlogPostDomain.new.call(url_from_generic_source)
    expect(parsed_domain).to eq('dev.bleacherreport.com')

    url_from_generic_source = 'http://blog.mojotech.com/safeguard-web-service-failures-in-elixir-with-fuse'
    parsed_domain = ParseBlogPostDomain.new.call(url_from_generic_source)
    expect(parsed_domain).to eq('blog.mojotech.com')
  end

  it 'returns a domain from a medium.com url' do
    url_from_medium_com = 'https://medium.com/@rschmukler/elixir-and-data-ingestion-ef5b2bd32d76'
    parsed_domain = ParseBlogPostDomain.new.call(url_from_medium_com)
    expect(parsed_domain).to eq('medium.com/@rschmukler')

    url_from_medium_com = 'https://medium.com/@rpw952/elixir-development-on-windows-10-ff7ca03769d'
    parsed_domain = ParseBlogPostDomain.new.call(url_from_medium_com)
    expect(parsed_domain).to eq('medium.com/@rpw952')
  end
end
