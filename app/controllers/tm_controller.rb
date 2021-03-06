class TmController < ApplicationController

    def index
          @tm = TmHelper::TM.new
    end

    def compute
        hash = TmHelper::FSM.convert_from_fsm(params['data'])
        hash = JSON.parse(hash) if hash.is_a?(String)

        @tm = TmHelper::TM.new
        @tm.states = hash['states']
        @tm.states.push('ACCEPT')
        @tm.states.push('REJECT')
        @tm.start = hash['start']
        @tm.inputAlphabet = hash['inputAlphabet']
        @tm.tapeAlphabet = hash['tapeAlphabet']
        @tm.transitions = hash['transitions']
        trans_map = Hash.new
        @tm.transitions.each do |t|
          if trans_map[t['current_state']] == nil
            trans_map[t['current_state']] = {
              t['symbol'] => {
                "to" => t['destination'],
                "write" => t['write'],
                "move" => t['move']
              }
            }
          else
            trans_map[t['current_state']] = trans_map[t['current_state']].merge({
              t['symbol'] => {
                "to" => t['destination'],
                "write" => t['write'],
                "move" => t['move']
              }
            })
          end
      end

      @tm.transitions = trans_map

      nodes = []
      edges = []

      @tm.states.each do |s|
          n = { data: { id: s }}
          nodes.push(n)
      end

      i = 1
      @tm.transitions.each do |keyt, valt|
        valt.each do |key, val|
          e = { data: {
            id: i.to_s,
            source: keyt,
            move: val['move'],
            target: val['to'],
            label: "#{key} -> #{val['write'] ? val['write'] : '&'}, #{val['move']}"
              }
          }
          edges.push(e)
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
        hash = TmHelper::FSM.convert_from_fsm(params['data'])
        hash = JSON.parse(hash) if hash.is_a?(String)

        @tm = TmHelper::TM.new
        @tm.states = hash['states']
        @tm.start = hash['start']
        #@tm.transitions = {"A"=>{"0"=>{"to"=>"A", "write"=>0, "move"=>"R"}, "1"=>{"to"=>"B", "write"=>1, "move"=>"R"}}, "B"=>{"1"=>{"to"=>"B", "write"=>1, "move"=>"R"}, "0"=>{"to"=>"C", "write"=>0, "move"=>"R"}}, "C"=>{"1"=>{"to"=>"ACCEPT", "write"=>1, "move"=>"R"}, "0"=>{"to"=>"A", "write"=>0, "move"=>"R"}}}
        @tm.transitions = hash['transitions']
        trans_map = Hash.new
        @tm.transitions.each do |t|
          if trans_map[t['current_state']] == nil
            trans_map[t['current_state']] = {
              t['symbol'] => {
                "to" => t['destination'],
                "write" => t['write'],
                "move" => t['move']
              }
            }
          else
            trans_map[t['current_state']] = trans_map[t['current_state']].merge({
              t['symbol'] => {
                "to" => t['destination'],
                "write" => t['write'],
                "move" => t['move']
              }
            })
          end
        end

        @tm.transitions = trans_map
        @tm.inputAlphabet = hash['inputAlphabet']
        @tm.tapeAlphabet = hash['tapeAlphabet']

        @compute = @tm.feed(params['string'])

        nodes = []
        edges = []

        @tm.states.each do |s|
            n = { data: { id: s }}
            nodes.push(n)
        end

        i = 1
        @tm.transitions.each do |keyt, valt|
          valt.each do |key, val|
            e = { data: {
              id: i.to_s,
              source: keyt,
              loqueron: key,
              move: val['move'],
              target: val['to'],
              label: "#{key} -> #{val['write'] ? val['write'] : '&'}, #{val['move']}"
                }
            }
            edges.push(e)
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
      def tm_params
      params.permit(:states, :alphabet, :start, :transitions, :input_string, :inputAlphabet, :tapeAlphabet)
    end

end
