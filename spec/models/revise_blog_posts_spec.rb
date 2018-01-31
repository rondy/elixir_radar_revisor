require 'rails_helper'

describe ReviseBlogPosts do
  it 'revises blog post entries from Elixir Radar' do
    VCR.use_cassette('blog_posts_various') do
      consistent_entry = {
        title: 'Integration Testing Phoenix Applications',
        url: 'https://medium.com/@boydm/integration-testing-phoenix-applications-b2a46acae9cb',
        subtitle: 'medium.com/@boydm',
        description: 'Check out phoenix_integration for server-side integration testing your Phoenix applications. It’s cool.',
        tag: 'blog-post'
      }

      divergent_entry = {
        title: 'Using Postgres range data type in Ecto',
        url: 'http://blog.mojotech.com/safeguard-web-service-failures-in-elixir-with-fuse',
        subtitle: 'blog.mojotech.com',
        description: 'If you are depending on external services that may fail, Omid Bachari has written an article on how to use the Fuse library for safeguarding your applications.',
        tag: 'blog-post'
      }

      entries = [consistent_entry, divergent_entry]

      revision_result = ReviseBlogPosts.new.call(entries)

      expect(revision_result.size).to eq(2)

      consistent_result_entry = revision_result.first
      expect(consistent_result_entry[:entry_title]).to eq('Integration Testing Phoenix Applications')
      expect(consistent_result_entry[:divergences]).to be_empty

      divergent_result_entry = revision_result.last
      expect(divergent_result_entry[:entry_title]).to eq('Using Postgres range data type in Ecto')
      expect(divergent_result_entry[:divergences]).to be_present
      expect(divergent_result_entry[:divergences].first[:reason]).to eq("page_title_does_not_match")
      expect(divergent_result_entry[:divergences].first[:details][:given_page_title]).to eq('Using Postgres range data type in Ecto')
      expect(divergent_result_entry[:divergences].first[:details][:fetched_page_title]).to eq('Safeguard web service failures in Elixir with Fuse')
    end
  end

  context 'when page title is not fetched from the title tag' do
    it 'fetches page title from the og:title property' do
      VCR.use_cassette('blog_post_consistent_og_title') do
        entry = {
          title: 'Phoenix Channels vs Rails Action Cable',
          url: 'https://dockyard.com/blog/2016/08/09/phoenix-channels-vs-rails-action-cable',
          subtitle: 'dockyard.com',
          tag: 'blog-post'
        }

        revision_result = ReviseBlogPosts.new.call([entry])

        consistent_result_entry = revision_result.first
        expect(consistent_result_entry[:entry_title]).to eq('Phoenix Channels vs Rails Action Cable')
        expect(consistent_result_entry[:divergences]).to be_empty
      end
    end
  end

  context 'when page title have difference regarding text case' do
    it 'matches title regardless of the case' do
      VCR.use_cassette('blog_post_consistent_title_tag') do
        entry = {
          # The fetched title will have 'phoenix' term, in lowercase.
          title: 'Passwordless login with Phoenix',
          url: 'http://inaka.net/blog/2016/07/27/passwordless-login-with-phoenix/',
          subtitle: 'inaka.net',
          tag: 'blog-post'
        }

        revision_result = ReviseBlogPosts.new.call([entry])

        consistent_result_entry = revision_result.first
        expect(consistent_result_entry[:entry_title]).to eq('Passwordless login with Phoenix')
        expect(consistent_result_entry[:divergences]).to be_empty
      end
    end
  end

  context 'when accessing the entry url raises an error' do
    it 'revises as a divergent event entry' do
      VCR.use_cassette('blog_post_not_found') do
        entry = {
          title: "Understanding Elixir's recompilation",
          url: 'http://milhouseonsoftware.com/2016/08/11/understanding-elixir-recompilation-error-404/',
          subtitle: 'milhouseonsoftware.com',
          tag: 'blog-post'
        }

        revision_result = ReviseBlogPosts.new.call([entry])

        divergent_result_entry = revision_result.last
        expect(divergent_result_entry[:entry_title]).to eq("Understanding Elixir's recompilation")
        expect(divergent_result_entry[:divergences]).to be_present
        expect(divergent_result_entry[:divergences].first[:reason]).to eq('connection_error')
        expect(divergent_result_entry[:divergences].first[:details][:error_message]).to eq('Mechanize::ResponseCodeError: 404 => Net::HTTPNotFound for http://milhouseonsoftware.com/2016/08/11/understanding-elixir-recompilation-error-404/ -- unhandled response')
      end
    end
  end

  it 'revises an blog post entry with consistent domain' do
    VCR.use_cassette('blog_post_consistent_domain') do
      entry = {
        title: 'Elixir/Phoenix Centralized HTTP Logging',
        url: 'https://dev.bleacherreport.com/elixir-phoenix-centralized-http-logging-aa50efe3105b',
        subtitle: 'dev.bleacherreport.com',
        tag: 'blog-post'
      }

      revision_result = ReviseBlogPosts.new.call([entry])

      divergent_result_entry = revision_result.last
      expect(divergent_result_entry[:entry_title]).to eq('Elixir/Phoenix Centralized HTTP Logging')
      expect(divergent_result_entry[:divergences]).to be_empty
    end
  end

  it 'revises an blog post entry with divergent domain' do
    VCR.use_cassette('blog_post_divergent_domain') do
      entry = {
        title: 'Elixir/Phoenix Centralized HTTP Logging',
        url: 'https://dev.bleacherreport.com/elixir-phoenix-centralized-http-logging-aa50efe3105b',
        subtitle: 'dev.bleacherreporty.com',
        tag: 'blog-post'
      }

      revision_result = ReviseBlogPosts.new.call([entry])

      divergent_result_entry = revision_result.last
      expect(divergent_result_entry[:entry_title]).to eq('Elixir/Phoenix Centralized HTTP Logging')
      expect(divergent_result_entry[:divergences]).to be_present
      expect(divergent_result_entry[:divergences].first[:reason]).to eq('domain_does_not_match')
      expect(divergent_result_entry[:divergences].first[:details][:given_domain]).to eq('dev.bleacherreporty.com')
      expect(divergent_result_entry[:divergences].first[:details][:fetched_domain]).to eq('dev.bleacherreport.com')
    end
  end

  it 'revises an blog post entry with consistent domain (from medium)' do
    VCR.use_cassette('blog_post_medium_consistent_domain') do
      entry = {
        title: 'Elixir and Data Ingestion',
        url: 'https://medium.com/@rschmukler/elixir-and-data-ingestion-ef5b2bd32d76',
        subtitle: 'medium.com/@rschmukler',
        tag: 'blog-post'
      }

      revision_result = ReviseBlogPosts.new.call([entry])

      divergent_result_entry = revision_result.last
      expect(divergent_result_entry[:entry_title]).to eq('Elixir and Data Ingestion')
      expect(divergent_result_entry[:divergences]).to be_empty
    end
  end

  it 'revises an blog post entry with divergent domain (from medium)' do
    VCR.use_cassette('blog_post_medium_divergent_domain') do
        entry = {
          title: 'Elixir and Data Ingestion',
          url: 'https://medium.com/@rschmukler/elixir-and-data-ingestion-ef5b2bd32d76',
          subtitle: 'medium.com/@rpw952',
          tag: 'blog-post'
        }

        revision_result = ReviseBlogPosts.new.call([entry])

        divergent_result_entry = revision_result.last
        expect(divergent_result_entry[:entry_title]).to eq('Elixir and Data Ingestion')
        expect(divergent_result_entry[:divergences]).to be_present
        expect(divergent_result_entry[:divergences].first[:reason]).to eq('domain_does_not_match')
        expect(divergent_result_entry[:divergences].first[:details][:given_domain]).to eq('medium.com/@rpw952')
        expect(divergent_result_entry[:divergences].first[:details][:fetched_domain]).to eq('medium.com/@rschmukler')
      end
  end
end
