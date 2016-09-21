module ApplicationHelper
  def present_divergence_reason(reason)
    {
      'page_title_does_not_match' => 'Título da página não confere',
      'domain_does_not_match' => 'Domínio do blog post não confere',
      'job_details_does_not_match' => 'Detalhes do job não confere',
      'event_title_does_not_match' => 'Título do evento não confere',
      'event_date_does_not_match' => 'Data do evento não confere',
      'connection_error' => 'Erro de conexão ao acessar a página externa',
    }[reason] || ''
  end

  def present_divergence_detail(field)
    {
      fetched_page_title: 'Título da página na página externa',
      given_domain: 'Domínio na newsletter',
      fetched_domain: 'Domínio presente na URL',
      given_job_details: 'Detalhes do job na newsletter',
      given_event_title: 'Título do evento na newsletter',
      fetched_event_title: 'Título do evento na página externa',
      given_event_date: 'Data do evento na newsletter',
      fetched_event_date: 'Data do evento na página externa',
      error_message: 'Mensagem de erro',
    }[field] || ''
  end
end
