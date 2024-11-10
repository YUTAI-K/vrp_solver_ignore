# Import the module
from vrp_solver_ignore import vrp_graph


# Step 1: Generate a random graph
n_customers = 8# Number of customers in the VRP
seed = 4643      # Seed for random number generation
capacity = 0.2  # Vehicle capacity, set to 25% of total capacity

# Generate the random graph
graph_tuple = vrp_graph.generate_random_graph(n_customers, seed, capacity)

# Unpack the returned tuple
graph = graph_tuple[0]  # The Graph object
vec1 = graph_tuple[1]   # X axis of the generated points
vec2 = graph_tuple[2]   # Y axis of the generated points

# Step 2: Inspect properties of the graph
print("Graph Properties:")
print("=================")
print(f"Number of vertices: {graph.n_vertices()}")
print(f"Number of customers: {graph.n_customers()}")
print(f"Departing depot index: {graph.departing_depot()}")
print(f"Returning depot index: {graph.returning_depot()}")
print(f"Capacity: {graph.capacity()}")

# Get customer indices
customers = list(graph.customers())
print(f"Customer indices: {customers}")

# Print demands for each vertex
print("\nVertex Demands:")
print("===============")
for i in range(graph.n_vertices()):
    demand = graph.demand(i)
    print(f"Vertex {i}: Demand = {demand}")

# Print costs between some pairs of vertices
print("\nSample Costs Between Vertices:")
print("==============================")
for i in customers:
    for j in customers:
        if (i != j):
            cost = graph.cost(i, j)
            print(f"Cost from vertex {i} to vertex {j}: {cost}")


