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
end
