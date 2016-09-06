require 'rails_helper'

describe ReviseBlogPosts do
  it 'revises blog post entries from Elixir Radar' do
    consistent_entry = {
      title: "Understanding Elixir's recompilation",
      url: 'http://milhouseonsoftware.com/2016/08/11/understanding-elixir-recompilation/',
      subtitle: 'milhouseonsoftware.com',
      description: "Renan Ranelli gives a deep dive on Elixir's recompilation process and its dependency tracking system and how to avoid common pitfalls.",
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
    expect(consistent_result_entry[:entry_title]).to eq("Understanding Elixir's recompilation")
    expect(consistent_result_entry[:divergences]).to be_empty

    divergent_result_entry = revision_result.last
    expect(divergent_result_entry[:entry_title]).to eq('Using Postgres range data type in Ecto')
    expect(divergent_result_entry[:divergences]).to be_present
    expect(divergent_result_entry[:divergences].first[:reason]).to eq("page_title_does_not_match")
    expect(divergent_result_entry[:divergences].first[:details][:fetched_page_title]).to eq('Safeguard web service failures in Elixir with Fuse')
  end

  context 'when page title is not fetched from the title tag' do
    it 'fetches page title from the og:title property' do
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

  context 'when page title have difference regarding text case' do
    it 'matches title regardless of the case' do
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