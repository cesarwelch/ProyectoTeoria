module NfaHelper

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
	end

	class NFA < Parent::Parent
		def consume(input)
			heads = [@start]

			if has_transition?(@start, '&')
			transition(@start, '&').each { |h| heads << h }
			end
			input.each_char do |symbol|
			newHeads, eTrans = [], []
			heads.each do |head|
				if has_transition?(head, symbol)
					transition(head, symbol).each { |t| newHeads << t }
				end
			end
			newHeads.each do |head|
				if has_transition?(head, '&')
					transition(head, '&').each { |t| eTrans << t }
				end
			end
			eTrans.each { |t| newHeads << t }
			heads = newHeads
			break if heads.empty?
			end

			accept = false
			heads.each { |head| accept = true if accept_state? head }

			resp = {
			input: input,
			accept: accept,
			heads: heads
			}
		end

		def accepts?(input)
			resp = consume(input)
			resp[:accept]
		end

		def transition(state, symbol)
			dests = @transitions[state][symbol]
			dests = [dests] unless dests.kind_of? Array
			dests
		end

		def has_transition?(state, symbol)
			return false unless @transitions.include? state
			@transitions[state].has_key? symbol
		end

		def accept_state?(state)
			@accept.include? state
		end

	end
end
