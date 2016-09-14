module ApplicationHelper
  def present_divergence_reason(reason)
    {
      'page_title_does_not_match' => 'Título da página não confere',
      'job_details_does_not_match' => 'Detalhes do job não confere',
      'event_title_does_not_match' => 'Título do evento não confere',
    }[reason] || ''
  end

  def present_divergence_detail(field)
    {
      fetched_page_title: 'Título da página na página externa',
      given_job_details: 'Detalhes do job na newsletter',
      given_event_title: 'Título do evento na newsletter',
      fetched_event_title: 'Título do evento na página externa',
    }[field] || ''
  end
end
