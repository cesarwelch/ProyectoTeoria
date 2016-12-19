class TmController < ApplicationController

    def index
          @tm = TmHelper::TM.new
    end

    def compute
        hash = tm_params
        hash = JSON.parse(hash) if hash.is_a?(String)

        @tm = TmHelper::TM.new
        @tm.states = hash['states'].split(',')
        @tm.states.push('ACCEPT')
        @tm.states.push('REJECT')
        @tm.start = hash['start']
        @tm.inputAlphabet = hash['inputAlphabet'].split(',')
        @tm.tapeAlphabet = hash['tapeAlphabet'].split(',')
        @tm.transitions = JSON.parse(hash['transitions'])
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
      #aqui
    end

      @tm.transitions = trans_map
      # {
      #   "A" => {
      #     "0" => {
      #       "to"=>"A",
      #       "write"=>0,
      #       "move"=>"R"
      #       },
      #     "1" => {
      #       "to"=>"B",
      #       "write"=>1,
      #       "move"=>"R"
      #     }
      #   },
      #   "B" => {
      #     "1" => {
      #       "to"=>"B",
      #       "write"=>1,
      #       "move"=>"R"
      #     },
      #     "0" => {
      #       "to"=>"C",
      #       "write"=>0,
      #       "move"=>"R"
      #     }
      #   },
      #   "C" => {
      #     "1" => {
      #       "to"=>"ACCEPT",
      #       "write"=>1,
      #       "move"=>"R"
      #     },
      #     "0" => {
      #       "to"=>"A",
      #       "write"=>0,
      #       "move"=>"R"
      #     }
      #   }
      # }


      nodes = []
      edges = []

end
