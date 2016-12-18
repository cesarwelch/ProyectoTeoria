require 'json'
module Parent
	class Parent
		attr_accessor :states, :alphabet, :start, :accept, :transitions
		def initialize(elements={})
			yaml = {}
			yaml = YAML::load_file(elements[:file]) if elements.has_key? :file
			@states = yaml['states'] || elements[:states]
			@alphabet = yaml['alphabet'] || elements[:alphabet]
			@start = yaml['start'] || elements[:start]
			@accept = yaml['accept'] || elements[:accept]
			@transitions = yaml['transitions'] || elements[:transitions]
			@transitions = Hash.keys_to_strings(@transitions)
		end
	end

	class Hash
		def self.keys_to_strings(element)
			return element unless element.kind_of? Hash
			element = element.inject({}){|h,(k,v)| h[k.to_s] = Hash.keys_to_strings(v); h}
			return element
		end
	end

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
			}
		end

		# def self.convert_to_fsm(elements={})

		# end
	end
end
