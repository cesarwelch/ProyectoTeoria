require 'json'

class PdaController < ApplicationController

  def index
      @pda = PdaHelper::PDA.new
  end

  def compute
      hash = PdaHelper::FSM.convert_from_fsm(params['data'])
      hash = JSON.parse(hash) if hash.is_a?(String)
      @pda = PdaHelper::PDA.new
      @pda.states = hash['states'] # ["S", "A", "B", "ha"]
      @pda.alphabet = hash['alphabet'] # ["(", ")", "&"]
      @pda.start = hash['start'] # "S"
      @pda.accept = hash['accept'] # "ha"
      @pda.stack_user = hash['stack_user']
      @pda.transitions =hash['transitions']
      trans_map = Hash.new
      @pda.transitions.each do |t|
        if trans_map[t['current_state']] == nil && t['push'] != '-' && t['push'] != nil && t['pop'] != '-' && t['pop'] != nil

          trans_map[t['current_state']] = {t['symbol'] => {"to"=>t['destination'],"push"=>t['push'],"pop"=>t['pop']}}
        else
          if trans_map[t['current_state']] == nil && t['push'] != '-' && t['push'] != nil && (t['pop'] == '-' || t['pop'] == nil)
            trans_map[t['current_state']] = {t['symbol'] => {"to"=>t['destination'],"push"=>t['push']}}
          else
            if trans_map[t['current_state']] == nil && t['pop'] != '-' && t['pop'] != nil && (t['push'] == '-' || t['push'] == nil)
              trans_map[t['current_state']] = {t['symbol'] => {"to"=>t['destination'],"pop"=>t['pop']}}

            else
              if trans_map[t['current_state']] != nil && t['push'] != '-' && t['push'] != nil && t['pop'] != '-' && t['pop'] != nil
                trans_map[t['current_state']] = trans_map[t['current_state']].merge({t['symbol'] => {"to"=>t['destination'],"push"=>t['push'],"pop"=>t['pop']}})
              else
                  if trans_map[t['current_state']] != nil && t['push'] != '-' && t['push'] != nil && (t['pop'] == '-' || t['pop'] == nil)
                    trans_map[t['current_state']] = trans_map[t['current_state']].merge({t['symbol'] => {"to"=>t['destination'],"push"=>t['push']}})
                  else
                      if trans_map[t['current_state']] != nil && t['pop'] != '-' && t['pop'] != nil && (t['push'] == '-' || t['push'] == nil)
                        trans_map[t['current_state']] = trans_map[t['current_state']].merge({t['symbol'] => {"to"=>t['destination'],"pop"=>t['pop']}})
                      end
                  end
              end
            end
          end
        end
      end
      @pda.transitions = trans_map

      nodes = []
      edges = []
      pp hash['states']
      @pda.states.each do |s|
          n = { data: { id: s }}
          nodes.push(n)
      end

      i = 1
      @pda.transitions.each do |keyt, valt|
        valt.each do |key, val|
          e = { data: {
            id: i.to_s,
            source: keyt,
            target: val['to'],
            label: "#{key}, #{val['pop'] ? val['pop'] : '&'} -> #{val['push'] ? val['push'] : '&'}"}
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
        hash = PdaHelper::FSM.convert_from_fsm(params['data'])
        hash = JSON.parse(hash) if hash.is_a?(String)
        @pda = PdaHelper::PDA.new
        @pda.states = hash['states']
        @pda.alphabet = hash['alphabet']
        @pda.start = hash['start']
        @pda.accept = hash['accept']
        @pda.stack_user = hash['stack_user']
        @pda.transitions = hash['transitions']
        trans_map = Hash.new
        @pda.transitions.each do |t|
          if trans_map[t['current_state']] == nil && t['push'] != '-' && t['push'] != nil && t['pop'] != '-' && t['pop'] != nil

            trans_map[t['current_state']] = {t['symbol'] => {"to"=>t['destination'],"push"=>t['push'],"pop"=>t['pop']}}
          else
            if trans_map[t['current_state']] == nil && t['push'] != '-' && t['push'] != nil && (t['pop'] == '-' || t['pop'] == nil)
              trans_map[t['current_state']] = {t['symbol'] => {"to"=>t['destination'],"push"=>t['push']}}
            else
              if trans_map[t['current_state']] == nil && t['pop'] != '-' && t['pop'] != nil && (t['push'] == '-' || t['push'] == nil)
                trans_map[t['current_state']] = {t['symbol'] => {"to"=>t['destination'],"pop"=>t['pop']}}

              else
                if trans_map[t['current_state']] != nil && t['push'] != '-' && t['push'] != nil && t['pop'] != '-' && t['pop'] != nil
                  trans_map[t['current_state']] = trans_map[t['current_state']].merge({t['symbol'] => {"to"=>t['destination'],"push"=>t['push'],"pop"=>t['pop']}})
                else
                    if trans_map[t['current_state']] != nil && t['push'] != '-' && t['push'] != nil && (t['pop'] == '-' || t['pop'] == nil)
                      trans_map[t['current_state']] = trans_map[t['current_state']].merge({t['symbol'] => {"to"=>t['destination'],"push"=>t['push']}})
                    else
                        if trans_map[t['current_state']] != nil && t['pop'] != '-' && t['pop'] != nil && (t['push'] == '-' || t['push'] == nil)
                          trans_map[t['current_state']] = trans_map[t['current_state']].merge({t['symbol'] => {"to"=>t['destination'],"pop"=>t['pop']}})
                        end
                    end
                end
              end
            end
          end
        end
        @pda.transitions = trans_map
        pp @pda.transitions
        @compute = @pda.consume(params['string'])

        nodes = []
        edges = []

        @pda.states.each do |s|
            n = { data: { id: s }}
            nodes.push(n)
        end

        i = 1
        @pda.transitions.each do |keyt, valt|
          valt.each do |key, val|
            e = { data: {
              id: i.to_s,
              loqueron: key,
              source: keyt,
              target: val['to'],
              label: "#{key}, #{val['pop'] ? val['pop'] : '&'} -> #{val['push'] ? val['push'] : '&'}"}
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

    def index
    end

    private
      def pda_params
        params.permit(:states, :alphabet, :start, :accept, :transitions, :input_string, :stack_user)
      end

end
