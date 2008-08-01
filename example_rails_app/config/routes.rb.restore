ActionController::Routing::Routes.draw do |map|
  map.resources :surveys do |survey|
    survey.resource :report, :controller =>'surveys/report'
  end

  map.connect ':controller/:action/:id'
end
