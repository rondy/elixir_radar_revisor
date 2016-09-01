Rails.application.routes.draw do
  resource :revisions, only: [:create]
end
