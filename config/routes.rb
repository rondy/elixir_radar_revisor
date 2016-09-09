Rails.application.routes.draw do
  resource :revisions, only: [:create]
  root 'bookmarklet#index'
end
