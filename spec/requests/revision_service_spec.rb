require 'rails_helper'

describe 'Revision service', type: :request do
  it 'revises blog post entries from Elixir Radar' do
    VCR.use_cassette('revision_service_blog_posts') do
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

      post '/revisions', params: {
        "entriesList" => [consistent_entry, divergent_entry]
      }

      response_body = parse_response_body(response.body)

      expect_to_render_revision_summary(response_body, 'Blog posts (2 links revisados, 1 divergência')

      expect_to_render_divergent_entry(
        response_body,
        entry_title: 'Using Postgres range data type in Ecto',
        divergence_reason: 'Título da página não confere',
        divergence_details: 'Título da página na página externa: Safeguard web service failures in Elixir with Fuse',
      )

      expect_not_to_render_consistent_entry(
        response_body,
        entry_title: 'Integration Testing Phoenix Applications'
      )
    end
  end

  it 'revises job entries from Elixir Radar' do
    VCR.use_cassette('revision_service_jobs') do
      consistent_entry = {
        title: 'Software Developer - Full Stack',
        subtitle: 'UTRUST - Braga, Portugal (remote)',
        url: 'https://utrust.breezy.hr/p/fbe2ca7222ef01-software-developer-full-stack?utm_campaign=elixir_radar_127&utm_medium=email&utm_source=RD+Station',
        tag: 'job'
      }

      divergent_entry = {
        title: 'Elixir Software Engineer',
        subtitle: 'The RealReal',
        url: 'https://www.thecitybase.com/positions/Elixir_Software_Engineer?gh_jid=985767&utm_campaign=elixir_radar_127&utm_medium=email&utm_source=RD+Station',
        tag: 'job'
      }

      post '/revisions', params: {
        "entriesList" => [consistent_entry, divergent_entry]
      }

      response_body = parse_response_body(response.body)

      expect_to_render_revision_summary(response_body, 'Jobs (2 links revisados, 1 divergência)')

      expect_to_render_divergent_entry(
        response_body,
        entry_title: 'Elixir Software Engineer',
        divergence_reason: 'Detalhes do job não confere',
        divergence_details: 'Detalhes do job na newsletter: The RealReal'
      )

      expect_not_to_render_consistent_entry(response_body, entry_title: 'Software Developer - Full Stack')
    end
  end

  it 'revises event entries from Elixir Radar', focus: true do
    VCR.use_cassette('revision_service_events') do
      consistent_entry = {
        title: 'ElixirConf',
        url: 'http://elixirconf.com/',
        description: 'ElixirConf™ US - Bellevue, WA, September 5-8, 2017.',
        tag: 'event'
      }

      divergent_entry = {
        title: 'EmpEx -- Halloween Lightning Talks 2016',
        url: 'http://empex.co/',
        description: 'Call for Proposals now open\n        <br>',
        tag: 'event'
      }

      post '/revisions', params: {
        "entriesList" => [consistent_entry, divergent_entry]
      }

      response_body = parse_response_body(response.body)

      expect_to_render_revision_summary(response_body, 'Events (2 links revisados, 1 divergência)')

      expect_to_render_divergent_entry(
        response_body,
        entry_title: 'EmpEx -- Halloween Lightning Talks 2016',
        divergence_reason: 'Título da página não confere',
        divergence_details: 'Título da página na página externa: EMPEX'
      )

      expect_not_to_render_consistent_entry(response_body, entry_title: 'ElixirConf')
    end
  end

  def parse_response_body(response_body)
    Capybara.string(response_body)
  end

  def expect_to_render_revision_summary(response_body, summary_content)
    expect(response_body).to have_content(summary_content)
  end

  def expect_to_render_divergent_entry(response_body, entry_title:, divergence_reason:, divergence_details:nil)
    expect(response_body).to have_content(entry_title)
    expect(response_body).to have_content(divergence_reason)
    expect(response_body).to have_content(divergence_details) if divergence_details
  end

  def expect_not_to_render_consistent_entry(response_body, entry_title:)
    expect(response_body).not_to have_content(entry_title)
  end
end
