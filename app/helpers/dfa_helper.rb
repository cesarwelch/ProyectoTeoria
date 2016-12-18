module DfaHelper

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
				link['text'].split(',').each do |c|
					if link['type'] == 'Link'
						from = element['nodes'][link['nodeA']]['text']
						to = element['nodes'][link['nodeB']]['text']
						with = c
					elsif link['type'] == 'SelfLink'
						from = element['nodes'][link['node']]['text']
						to = element['nodes'][link['node']]['text']
						with = c
					end
					if link['type'] != 'StartLink'
						alphabet.add(c)
						transitions.push({
							"current_state": from,
							"symbol": with,
							"destination": to
						})
					end
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

		# def self.convert_to_fsm(elements={})

		# end
	end

	class DFA < Parent::Parent
		def check?
			@transitions.each do |key, val|
				@alphabet.each do |a|
					return false unless @transitions[key].has_key? a.to_s
				end
			end
			resp = {
				check: true,
				states: @states,
				alphabet: @alphabet,
				start: @start,
				accept_state: @accept,
				transitions: @transitions
			}
			resp
		end

		def consume(input)
			head = @start.to_s
			movements = [{state: @start.to_s, via: "-"}]
			input.each_char {
				|symbol| head = @transitions[head][symbol]
				movements.push({state: head, via: symbol})
			}
			accept = is_accept_state? head
			resp = {
				input: input,
				accept: accept,
				head: head,
				movements: movements,
				states: @states,
				alphabet: @alphabet,
				start: @start,
				accept_state: @accept,
				transitions: @transitions
			}
			resp
		end

		def accepts?(input)
			resp = feed(input)
			resp[:accept]
		end

		def is_accept_state?(state)
			@accept.include? state.to_s
		end
	end
end
