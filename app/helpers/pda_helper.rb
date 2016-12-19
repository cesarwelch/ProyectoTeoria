module PdaHelper

	class FSM
		def self.convert_from_fsm(json)
			element = JSON.parse(json)

			alphabet = Set.new
			accept = Set.new
			states = Set.new
			transitions = []
			start = nil

			element['nodes'].each do |node|
				states.add(node['text'])
				if node['isAcceptState']
					accept.add(node['text'])
				end
			end
			element['links'].each do |link|
				if link['type'] == 'Link'
					from = element['nodes'][link['nodeA']]['text']
					to = element['nodes'][link['nodeB']]['text']
					with = link['text'].split(',')[0]
					push = link['text'].split(',')[1].split('->')[0]
					pop = link['text'].split(',')[1].split('->')[1]
				elsif link['type'] == 'SelfLink'
					from = element['nodes'][link['node']]['text']
					to = element['nodes'][link['node']]['text']
					with = link['text'].split(',')[0]
					push = link['text'].split(',')[1].split('->')[0]
					pop = link['text'].split(',')[1].split('->')[1]
				end
				if link['type'] != 'StartLink'
					if with != '&'
						alphabet.add(with)
					end
					transitions.push({
						"current_state": from,
						"symbol": with,
						"destination": to,
						"push": push,
						"pop": pop
					})
				end
				if link['type'] == 'StartLink'
					start = element['nodes'][link['node']]['text']
				end
			end
			return {
				"alphabet": alphabet.to_a,
				"accept": accept.to_a,
				"states": states.to_a,
				"transitions": transitions,
				"start": start
			}.to_json
		end
	end

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

		def pop?(symbol)
			@stack.last == symbol
		end


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


		def accept_state?(state)
			@accept.include? state
		end

		def includes_accept_state?(states)
			states.each { |s| return true if accept_state? s }
			return false
		end


		def consume(input)
			movements = []
			heads, @stack, accept = [@start], [], false

			eTrans = transition(@start, '&') if has_transition?(@start, '&')

			heads += eTrans
			count = 0
			heads.each do |vary|
				if count==0
					movements.push({state: vary, via: "-"})
				else
					movements.push({state: vary, via: "&"})
				end
				count = count+1
			end

			input.each_char do |symbol|
				newHeads = []
				heads.each do |head|
					if has_transition?(head, symbol)
						transition(head, symbol).each { |t| newHeads << t 
							
						}
						
					end
				end
				newHeads.each do |pejui|
					movements.push({state: pejui, via: symbol})
				end
				heads = newHeads
				
				break if heads.empty?
			end
			accept = includes_accept_state? heads
			resp = {
				input: input,
				accept: accept,
				heads: heads,
				stack: @stack,
				movements: movements,
                states: @states,
                alphabet: @alphabet,
                start: @start,
                accept_state: @accept,
                transitions: @transitions
			}
		end
	end
end