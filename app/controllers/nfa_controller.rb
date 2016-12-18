class NfaController < ApplicationController
	def index
        @nfa = NfaHelper::NFA.new
    end

    def compute
        hash = NfaHelper::FSM.convert_from_fsm(params['data'])
        hash = JSON.parse(hash) if hash.is_a?(String)
        @nfa = NfaHelper::NFA.new()
        @nfa.states = hash['states']
        @nfa.alphabet = hash['alphabet']
        @nfa.start = hash['start']
        @nfa.accept = hash['accept']
        @nfa.transitions = hash['transitions']
        trans_map = Hash.new
        @nfa.transitions.each do |t|
          if trans_map[t['current_state']] == nil
            trans_map[t['current_state']] = {t['symbol'] => t['destination']}
          else
            trans_map[t['current_state']] = trans_map[t['current_state']].merge({t['symbol'] => t['destination']})
          end
        end
        @nfa.transitions = trans_map
      nodes = []
      edges = []

      @nfa.states.each do |s|
        n = { data: { id: s } }
        nodes.push(n)
      end

      i = 1
      @nfa.transitions.each do |keyt, valt|
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
        hash = NfaHelper::FSM.convert_from_fsm(params['data'])
        hash = JSON.parse(hash) if hash.is_a?(String)
        @nfa = NfaHelper::NFA.new()
        @nfa.states = hash['states']
        @nfa.alphabet = hash['alphabet']
        @nfa.start = hash['start']
        @nfa.accept = hash['accept']
        @nfa.transitions = hash['transitions']
        trans_map = Hash.new
        @nfa.transitions.each do |t|
          if trans_map[t['current_state']] == nil
            trans_map[t['current_state']] = {t['symbol'] => t['destination']}
          else
            trans_map[t['current_state']] = trans_map[t['current_state']].merge({t['symbol'] => t['destination']})
          end
        end
        @nfa.transitions = trans_map
        @compute = @nfa.consume(params['string'])

        nodes = []
        edges = []

        @nfa.states.each do |s|
          n = { data: { id: s } }
          nodes.push(n)
        end

        i = 1
        @nfa.transitions.each do |keyt, valt|
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
        def nfa_params
          params.permit(:states, :alphabet, :start, :accept, :transitions, :input_string, :test)
        end
end
