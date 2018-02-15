require 'rails_helper'

describe ApplicationHelper do
  describe '#present_divergence_reason' do
    it 'presents a divergence reason in a human friendly format' do
      expect(present_divergence_reason('page_title_does_not_match')).to eq('Título da página não confere')
      expect(present_divergence_reason('domain_does_not_match')).to eq('Domínio do blog post não confere')
      expect(present_divergence_reason('job_details_does_not_match')).to eq('Detalhes do job não confere')
      expect(present_divergence_reason('event_title_does_not_match')).to eq('Título do evento não confere')
      expect(present_divergence_reason('event_description_does_not_match')).to eq('Detalhes do evento não confere')
      expect(present_divergence_reason('connection_error')).to eq('Erro de conexão ao acessar a página externa')
    end
  end

  describe '#present_divergence_detail' do
    it 'presents a divergence detail in a human friendly format' do
      expect(present_divergence_detail(:given_page_title)).to eq('Título da página na newsletter')
      expect(present_divergence_detail(:fetched_page_title)).to eq('Título da página na página externa')
      expect(present_divergence_detail(:given_domain)).to eq('Domínio na newsletter')
      expect(present_divergence_detail(:fetched_domain)).to eq('Domínio presente na URL')
      expect(present_divergence_detail(:given_job_details)).to eq('Detalhes do job na newsletter')
      expect(present_divergence_detail(:given_event_title)).to eq('Título do evento na newsletter')
      expect(present_divergence_detail(:fetched_event_title)).to eq('Título do evento na página externa')
      expect(present_divergence_detail(:given_event_title)).to eq('Título do evento na newsletter')
      expect(present_divergence_detail(:fetched_event_title)).to eq('Título do evento na página externa')
      expect(present_divergence_detail(:given_event_description)).to eq('Detalhes do evento na newsletter')
      expect(present_divergence_detail(:fetched_event_description)).to eq('Detalhes do evento na página externa')
      expect(present_divergence_detail(:error_message)).to eq('Mensagem de erro')
    end
  end
end
