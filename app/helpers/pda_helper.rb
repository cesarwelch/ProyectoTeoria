module PdaHelper

  class PDA < NfaHelper::NFA
    attr_accessor :stack_user

    def initialize(params={})
      super(params)
      @alphabet << '&' unless !@alphabet || @alphabet.include?('&')
      @stack = []
      @stack_user = params['stack_user']
		end

    def accepts?(input)
      resp = consume(input)
      resp[:accept]
    end

    def transition(state, symbol, stackTop=nil)
      dests = []

			if has_transition?(state, symbol)
				actions = @transitions[state][symbol]
				stackTop ||= @stack.last
				able = true
				@stack.push actions['push'] if actions['push']
				if actions['pop']
					able = false unless stackTop == actions['pop']
					@stack.pop if able
				end

        if able
					dests << actions['to']

					if has_transition?(actions['to'], '&')
						actions = @transitions[actions['to']]['&']
						able = true
						@stack.push actions['push'] if actions['push']
						if actions['pop']
							able = false unless @stack.last == actions['pop']
							@stack.pop if able
					  end
					if able
							dests << actions['to']
					end
				end
          dests
        else
          return dests
        end
        else
          return []
        end
      end
    end

    #metodo pop

    #metodo has_transition
    def has_transition?(state, symbol)
      return false unless @transitions.has_key? state
      if @transitions[state].has_key? symbol
        actions = @transitions[state][symbol]
        return false if actions['pop'] && @stack.last != actions['pop']
        return true
      else
        return false
      end
    end

  end
end
