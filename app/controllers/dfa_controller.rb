require 'json'

class DfaController < ApplicationController
    def index
        @dfa = DfaHelper::DFA.new
    end

    def compute
        hash = DfaHelper::FSM.convert_from_fsm(params['data'])
        hash = JSON.parse(hash) if hash.is_a?(String)
        @dfa = DfaHelper::DFA.new()
        @dfa.states = hash['states']
        @dfa.alphabet = hash['alphabet']
        @dfa.start = hash['start']
        @dfa.accept = hash['accept']
        @dfa.transitions = hash['transitions']
        trans_map = Hash.new
        @dfa.transitions.each do |t|
          if trans_map[t['current_state']] == nil
            trans_map[t['current_state']] = {t['symbol'] => t['destination']}
          else
            trans_map[t['current_state']] = trans_map[t['current_state']].merge({t['symbol'] => t['destination']})
          end
        end
        @dfa.transitions = trans_map
      nodes = []
      edges = []

      @dfa.states.each do |s|
        n = { data: { id: s } }
        nodes.push(n)
      end

      i = 1
      @dfa.transitions.each do |keyt, valt|
        valt.each do |key, val|
          n = { data: { id: "#{i}", source: keyt, target: val, label: key } }
          edges.push(n)
          i = i+1
        end
      end
      response = {
          nodes: nodes,
          edges: edges
        }.to_json
      render :json => response
    end

    def consume
        hash = DfaHelper::FSM.convert_from_fsm(params['data'])
        hash = JSON.parse(hash) if hash.is_a?(String)
        @dfa = DfaHelper::DFA.new()
        @dfa.states = hash['states']
        @dfa.alphabet = hash['alphabet']
        @dfa.start = hash['start']
        @dfa.accept = hash['accept']
        @dfa.transitions = hash['transitions']
        trans_map = Hash.new
        @dfa.transitions.each do |t|
          if trans_map[t['current_state']] == nil
            trans_map[t['current_state']] = {t['symbol'] => t['destination']}
          else
            trans_map[t['current_state']] = trans_map[t['current_state']].merge({t['symbol'] => t['destination']})
          end
        end
        @dfa.transitions = trans_map
        @compute = @dfa.consume(params['string'])

        nodes = []
        edges = []

        @dfa.states.each do |s|
          n = { data: { id: s } }
          nodes.push(n)
        end

        i = 1
        @dfa.transitions.each do |keyt, valt|
          valt.each do |key, val|
            n = { data: { id: i.to_s, source: keyt, target: val, label: key } }
            edges.push(n)
            i = i+1
          end
        end

        response = {
          nodes: nodes,
          edges: edges,
          movements: @compute[:movements],
          accept: @compute[:accept]
        }.to_json
        render :json => response
    end

    private
        def dfa_params
          params.permit(:states, :alphabet, :start, :accept, :transitions, :input_string, :test)
        end
end
