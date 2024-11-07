from vrp_solver_ignore import Solver_Ignore_Multiplicity, vrp_graph

n_customers = 18# Number of customers in the VRP
seed = 4643      # Seed for random number generation
capacity = 0.2  # Vehicle capacity, set to 25% of total capacity

# Generate the random graph
graph_tuple = vrp_graph.generate_random_graph(n_customers, seed, capacity)

# Unpack the returned tuple
graph = graph_tuple[0]  # The Graph object
vec1 = graph_tuple[1]   # X axis of the generated points
vec2 = graph_tuple[2]   # Y axis of the generated points

solver1 = Solver_Ignore_Multiplicity(graph)
solver1.solve()
solver1.plot_vrp_routes