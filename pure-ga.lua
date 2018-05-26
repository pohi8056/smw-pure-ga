population = {}
FRAME_COUNT = 20000
POPULATION_SIZE = 16
JUMP_WEIGHT	= 0.05
RIGHT_WEIGHT = 0.2
MUTATION_RATE = 0.1
BEST_FITNESS = 0
FILE_NAME = "SMB1-1.state"
ROM_NAME = "Super.Mario.World.1.smc"
controller = {}
math.randomseed(os.time())
math.random();math.random();

function elitism()
	local best_fitness = 0
	local elite_individual = 0
	for i=1, POPULATION_SIZE do
		if population[i].fitness > best_fitness then
			best_fitness = population[i].fitness
			elite_individual = i
			-- BEST_FITNESS = best_fitness
		end
	end
	return elite_individual
end

function roulette_wheel_selection(current_pop)
	local individual_probs = {}
	local previous_prob = 0
	local total_fitness_in_gen = 0
	local individual_selected_index = 0

	for i=1,POPULATION_SIZE do
		total_fitness_in_gen = total_fitness_in_gen + current_pop[i].fitness
	end

	local rand_prob = math.random()


	-- console.writeline("total " .. total_fitness_in_gen)
	for i=1,POPULATION_SIZE do
		individual_probs[i] = (current_pop[i].fitness/total_fitness_in_gen)
	end

	for i=1,POPULATION_SIZE do
		rand_prob = rand_prob - individual_probs[i]
		-- console.writeline("Rand_prob " .. rand_prob)
		if rand_prob < 0 then
			individual_selected_index = i
			break
		end
	end
	-- console.writeline("Parent: " .. individual_selected_index)
	return current_pop[individual_selected_index]
end

function mutate_individual(individual)
	local mutated_individual = {}
	mutated_individual.move_DNA = {}
	local possible_mutation_targets = {11, 12, 21, 22}
	for i=1, #individual.move_DNA do
		if math.random() < MUTATION_RATE then
			local mutate_target_rand = math.random(1,4)
			-- console.writeline("LOL " .. possible_mutation_targets[mutate_target_rand])

			--if mutate_rand < individual.move_DNA[i] == 11  then
			mutated_individual.move_DNA[i] = possible_mutation_targets[mutate_target_rand]
			--else if individual.move_DNA[i] == 12 then

			--else if individual.move_DNA[i] == 21 then
			--else if individual.move_DNA[i] == 22 then
		else
			mutated_individual.move_DNA[i] = individual.move_DNA[i]
		end
	end
	return mutated_individual
end

function switch_DNA(point1, point2, father, mother, child)
	for i = 1,point1 do
		child.move_DNA[i] = father.move_DNA[i]
	end
	for i = point1,point2 do
		child.move_DNA[i] = mother.move_DNA[i]
	end
	for i = point2,#father.move_DNA do
		child.move_DNA[i] = father.move_DNA[i]
	end

	--console.writeline("Mother# " .. #father.move_DNA)
	--console.writeline("Father# " .. #mother.move_DNA)
	--console.writeline("Child# " .. #child.move_DNA)
	--console.writeline("--- ")

	return child
end


function two_point_crossover(father, mother)
	local child = {}
	child.move_DNA = {}
	local crossover_point_1 = math.random(1, #father.move_DNA)
	local crossover_point_2 = math.random(1, #mother.move_DNA)

	if crossover_point_1 < crossover_point_2 then
		child = switch_DNA(crossover_point_1, crossover_point_2, father, mother, child)
	else
		child = switch_DNA(crossover_point_2, crossover_point_1, father, mother, child)
	end
	return child
end


function evolve()
	local new_population = {}
	-- Best individual of previous generation is guaranteed to proceed unmutated
	new_population[#new_population+1] = population[elitism()]
	-- Roulette wheel a father and mother
	--console.writeline("sdddd: " .. POPULATION_SIZE)
	--console.writeline("sdfsdf" .. #population)
	for i=2,POPULATION_SIZE do
		local father = roulette_wheel_selection(population)
		local mother = roulette_wheel_selection(population)

		new_population[#new_population+1] = two_point_crossover(father, mother)
	end

	for i=2,POPULATION_SIZE do
		new_population[i] = mutate_individual(new_population[i])
	end
	population = new_population
	--console.writeline("p3333" .. #new_population)
	-- return newPopulation
end

function initialize_individual()
	local individual = {}
	individual.move_DNA = {}
 	--move_DNA = "__"

	for i=0, FRAME_COUNT do
		math.random()
		jump_rand = math.random()
		math.random()
		right_rand = math.random()
		if (jump_rand < JUMP_WEIGHT) and (right_rand < RIGHT_WEIGHT) then
			individual.move_DNA[i] = 11
		elseif (jump_rand < JUMP_WEIGHT) and (right_rand >= RIGHT_WEIGHT) then
			individual.move_DNA[i] = 11
		elseif (jump_rand >= JUMP_WEIGHT) and (right_rand < RIGHT_WEIGHT) then
			individual.move_DNA[i] = 11
		elseif (jump_rand >= JUMP_WEIGHT) and (right_rand >= RIGHT_WEIGHT) then
			individual.move_DNA[i] = 11
		else
			console.writeline("NOT GIVEN BINARY DNA")
		end
		-- move_DNA = move_DNA .. individual.move_DNA[#individual.move_DNA]
		--console.writeline("indi move" .. individual.move_DNA[0])
	end
	return individual
end

function initialize_population()
	for count=0,POPULATION_SIZE do
		population[count] = initialize_individual()
	end
end

function match_DNA_with_move(i, sequence_index, controller)

	if population[i].move_DNA[sequence_index] == 11 then
		controller["P1 Right"] = false
		controller["P1 B"] = false
	elseif population[i].move_DNA[sequence_index] == 12 then
		controller["P1 Right"] = false
		controller["P1 B"] = true
	elseif population[i].move_DNA[sequence_index] == 21 then
		controller["P1 Right"] = true
		controller["P1 B"] = false
	elseif population[i].move_DNA[sequence_index] == 22 then
		controller["P1 Right"] = true
		controller["P1 B"] = true
	else
		console.write("------>ERROR: move_DNA not binary<------")
		console.writeline("Index: " .. i)
		console.writeline("Sequence index: " .. sequence_index)

		-- console.writeline("Data: " .. population[i].move_DNA[sequence_index])
		console.writeline("Full: " .. population[i].move_DNA)

	end
	controller["P1 Y"] = true
	return controller
end

function draw_info(ind_index)
	gui.drawBox(0, 35, 160, 75, 0xBBBBBBBBBB, 0xAAAAAAAAAAA)
	gui.drawText(0, 35, "Gen: " .. generation .. ", Ind: " .. ind_index .. " of " .. POPULATION_SIZE, 0xFFFFFFFF, 8)
	gui.drawText(0, 45, "Fitness = " .. population[ind_index].fitness, 0xFFFFFFFF, 8)
	gui.drawText(0, 55, "Best Fitness = " .. BEST_FITNESS, 0xFFFFFFFF, 8)

end

function iterate_individual(i)
	population[i].fitness = memory.read_s16_le(0x94) -- Calculate mario's X position
	if population[i].fitness > BEST_FITNESS then
		BEST_FITNESS = population[i].fitness
	end
	population[i].frame_number = population[i].frame_number + 1
	-- console.writeline("Read: " .. population[i].fitness)
end

initialize_population()
console.writeline("Begin simulation with generating a random pop.")
generation = 0
local modulo = 200
while true do
	generation = generation + 1
	console.writeline("GENERATION: " .. generation)

	if generation == 1 then
		mudolo = 20
	else
		modulo = 300
	end
	for i = 1, #population do
		local sequence_index = 1
		savestate.load(FILE_NAME)
		population[i].frame_number = 0
		population[i].fitness_history = -1
		console.writeline("POP #: " .. i)
		-- console.writeline("Population size: " .. #population)
		-- console.writeline("Move dna : " .. #population[i].move_DNA)

		while true do
			controller = {}
			iterate_individual(i)
			draw_info(i)

			controller = match_DNA_with_move(i, sequence_index, controller)
			sequence_index = sequence_index + 1
			joypad.set(controller)

			emu.frameadvance();



			if population[i].fitness_history == population[i].fitness then
				break
			end

			if sequence_index % modulo == 0 then
				population[i].fitness_history = population[i].fitness
				console.writeline("Timeout after " .. modulo .. " frames")
			end


			if memory.readbyte(0x0071) == 09 then -- if mario has 5< lives, restart.
				console.writeline("Died on sequence_index " .. sequence_index)
				break
			end
		end
		-- console.writeline("FITNESS:" .. population[i].fitness)
		-- console.writeline("Best fitness previous gen:" .. BEST_FITNESS)

	end
	evolve()

end
