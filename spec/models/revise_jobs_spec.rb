require 'rails_helper'

describe ReviseJobs do
  it 'revises job entries from Elixir Radar' do
    VCR.use_cassette('jobs_various') do
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

      entries = [consistent_entry, divergent_entry]

      revision_result = ReviseJobs.new.call(entries)

      expect(revision_result.size).to eq(2)

      consistent_result_entry = revision_result.first
      expect(consistent_result_entry[:entry_title]).to eq('Software Developer - Full Stack')
      expect(consistent_result_entry[:divergences]).to be_empty

      divergent_result_entry = revision_result.last
      expect(divergent_result_entry[:entry_title]).to eq('Elixir Software Engineer')
      expect(divergent_result_entry[:divergences]).to be_present
      expect(divergent_result_entry[:divergences].first[:reason]).to eq('job_details_does_not_match')
      expect(divergent_result_entry[:divergences].first[:details][:given_job_details]).to eq('The RealReal')
    end
  end

  context 'when accessing the entry url raises an error' do
    it 'revises as a divergent event entry', focus: true do
      VCR.use_cassette('job_not_found') do
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
end
