require 'rails_helper'

describe ReviseJobs do
  it 'revises job entries from Elixir Radar' do
    consistent_entry = {
      title: 'Elixir Developer',
      subtitle: 'Mediteo GmbH - Berlin/Remote',
      url: 'https://mediteo-gmbh.workable.com/jobs/319472',
      tag: 'job'
    }

    divergent_entry = {
      title: 'Desenvolvedor Elixir/Phoenix ou back-end sênior disposto a aprender',
      subtitle: 'The RealReal - San Francisco, CA, United States',
      url: 'http://techblog.fredapp.com.br/estamos-em-busca-de-desenvolvedor-back-end-elixir-e-phoenix-ou-ruby-on-rails-lisp-clojure-ou-haskell-e-disposto-a-aprender-elixir/',
      tag: 'job'
    }

    entries = [consistent_entry, divergent_entry]

    revision_result = ReviseJobs.new.call(entries)

    expect(revision_result.size).to eq(2)

    consistent_result_entry = revision_result.first
    expect(consistent_result_entry[:entry_title]).to eq('Elixir Developer')
    expect(consistent_result_entry[:divergences]).to be_empty

    divergent_result_entry = revision_result.last
    expect(divergent_result_entry[:entry_title]).to eq('Desenvolvedor Elixir/Phoenix ou back-end sênior disposto a aprender')
    expect(divergent_result_entry[:divergences]).to be_present
    expect(divergent_result_entry[:divergences].first[:reason]).to eq('job_details_does_not_match')
    expect(divergent_result_entry[:divergences].first[:details][:given_job_details]).to eq('The RealReal')
  end

  context 'when accessing the entry url raises an error' do
    it 'revises as a divergent event entry' do
      entry = {
        title: 'Desenvolvedor Elixir/Phoenix ou back-end sênior disposto a aprender',
        subtitle: 'The RealReal - San Francisco, CA, United States',
        url: 'http://techblog.fredapp.com.br/estamos-em-busca-de-desenvolvedor-back-end-elixir-404/',
        tag: 'job'
      }

      revision_result = ReviseJobs.new.call([entry])

      divergent_result_entry = revision_result.last
      expect(divergent_result_entry[:entry_title]).to eq('Desenvolvedor Elixir/Phoenix ou back-end sênior disposto a aprender')
      expect(divergent_result_entry[:divergences]).to be_present
      expect(divergent_result_entry[:divergences].first[:reason]).to eq('connection_error')
      expect(divergent_result_entry[:divergences].first[:details][:error_message]).to eq('Mechanize::ResponseCodeError: 404 => Net::HTTPNotFound for http://techblog.fredapp.com.br/estamos-em-busca-de-desenvolvedor-back-end-elixir-404/ -- unhandled response')
    end
  end
end
