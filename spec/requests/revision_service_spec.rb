require 'rails_helper'

describe 'Revision service', type: :request do
  it 'revises blog post entries from Elixir Radar' do
    consistent_entry = {
      'title' => "Understanding Elixir's recompilation",
      'url' => 'http://milhouseonsoftware.com/2016/08/11/understanding-elixir-recompilation/',
      'subtitle' => 'milhouseonsoftware.com',
      'tag' => 'blog-post'
    }

    divergent_entry = {
      'title' => 'Using Postgres range data type in Ecto',
      'url' => 'http://blog.mojotech.com/safeguard-web-service-failures-in-elixir-with-fuse',
      'subtitle' => 'blog.mojotech.com',
      'tag' => 'blog-post'
    }

    post '/revisions', params: {
      "entriesList" => [consistent_entry, divergent_entry]
    }

    response_body = Capybara.string(response.body)

    expect_to_render_revision_summary(response_body, 'Blog posts (2 links revisados, 1 divergência')

    expect_to_render_divergent_entry(
      response_body,
      entry_title: 'Using Postgres range data type in Ecto',
      divergence_reason: 'page_title_does_not_match',
      divergence_details: 'fetched_page_title: Safeguard web service failures in Elixir with Fuse',
    )

    expect_not_to_render_consistent_entry(
      response_body,
      entry_title: "Understanding Elixir's recompilation"
    )
  end

  it 'revises job entries from Elixir Radar' do
    consistent_entry = {
      'title' => 'Elixir Developer',
      'url' => 'https://mediteo-gmbh.workable.com/jobs/319472',
      'subtitle' => 'Mediteo GmbH - Berlin/Remote',
      'tag' => 'job'
    }

    divergent_entry = {
      'title' => 'Desenvolvedor Elixir/Phoenix ou back-end sênior disposto a aprender',
      'url' => 'http://techblog.fredapp.com.br/estamos-em-busca-de-desenvolvedor-back-end-elixir-e-phoenix-ou-ruby-on-rails-lisp-clojure-ou-haskell-e-disposto-a-aprender-elixir/',
      'subtitle' => 'The RealReal - San Francisco, CA, United States',
      'tag' => 'job'
    }

    post '/revisions', params: {
      "entriesList" => [consistent_entry, divergent_entry]
    }

    response_body = Capybara.string(response.body)

    expect_to_render_revision_summary(response_body, 'Jobs (2 links revisados, 1 divergência)')

    expect_to_render_divergent_entry(
      response_body,
      entry_title: 'Desenvolvedor Elixir/Phoenix ou back-end sênior disposto a aprender',
      divergence_reason: 'job_details_does_not_match',
      divergence_details: 'given_job_details: The RealReal'
    )

    expect_not_to_render_consistent_entry(response_body, entry_title: 'Elixir Developer')
  end

  it 'revises event entries from Elixir Radar' do
    consistent_entry = {
      'title' => 'ElixirConf',
      'url' => 'http://elixirconf.com/',
      'subtitle' => 'Conference = (DOLAR)450; Conference + Training = (DOLAR)700. (expiration: August 22)\n            <br>',
      'tag' => 'event'
    }

    divergent_entry = {
      'title' => 'EmpEx -- Halloween Lightning Talks 2016',
      'url' => 'http://empex.co/',
      'subtitle' => 'Call for Proposals now open\n        <br>',
      'tag' => 'event'
    }

    post '/revisions', params: {
      "entriesList" => [consistent_entry, divergent_entry]
    }

    response_body = Capybara.string(response.body)

    expect_to_render_revision_summary(response_body, 'Events (2 links revisados, 1 divergência)')

    expect_to_render_divergent_entry(
      response_body,
      entry_title: 'EmpEx -- Halloween Lightning Talks 2016',
      divergence_reason: 'page_title_does_not_match',
      divergence_details: 'fetched_page_title: Empire City Elixir Conf'
    )

    expect_not_to_render_consistent_entry(response_body, entry_title: 'ElixirConf')
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
