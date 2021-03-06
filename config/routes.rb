Rails.application.routes.draw do
  root 'automata_test#index'
  
  post '/test/receive', to: 'dfa#test', as: :test

  get '/nfa', to: 'nfa#index', as: :nfa
  post '/nfa/compute', to: 'nfa#compute', as: :nfa_compute
  post '/nfa/consume', to: 'nfa#consume', as: :nfa_consume

  get '/dfa', to: 'dfa#index', as: :dfa
  post '/dfa/compute', to: 'dfa#compute', as: :dfa_compute
  post '/dfa/consume', to: 'dfa#consume', as: :dfa_consume

  get '/pda', to: 'pda#index', as: :pda
  post '/pda/compute', to: 'pda#compute', as: :pda_compute
  post '/pda/consume', to: 'pda#consume', as: :pda_consume

  get '/tm', to: 'tm#index', as: :tm
  post '/tm/compute', to: 'tm#compute', as: :tm_compute
  post '/tm/consume', to: 'tm#consume', as: :tm_consume

  get '/cfg', to: 'cfg#index', as: :cfg
end
