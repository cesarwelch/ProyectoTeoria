module RegexHelper

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

end
