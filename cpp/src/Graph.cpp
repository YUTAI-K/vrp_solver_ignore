#include "Graph.h"
#include <boost/graph/adjacency_list.hpp>
#include <random>
#include <algorithm>
#include <numeric>

std::tuple<Graph, std::vector<double>, std::vector<double>>
generate_random_graph(size_t n_customers, unsigned int seed, double capacity) {
    std::mt19937 generator{seed}; // selecting generator
    std::uniform_real_distribution<> uni{1.0, 11.0}; // unif(1,101)
    const auto n_vertices = n_customers + 2u; // the plus 2 are vertices of depots

    std::vector<double> xs(n_vertices), ys(n_vertices), demand(n_vertices);

    // [&] () { return uni(generator); } is a lambda function.
    // [&] captures all local variables
    std::generate(xs.begin(), xs.end(), [&] () { return uni(generator); });
    std::generate(ys.begin(), ys.end(), [&] () { return uni(generator); });
    std::generate(demand.begin(), demand.end(), [&] () { return uni(generator); });

    // No demand at the start of finish depot
    demand[0u] = 0.0;
    demand[n_vertices - 1u] = 0.0;

    const auto max_demand = *std::ranges::max_element(demand);
    const double total_demand = std::accumulate(demand.begin(), demand.end(), 0);
    if (capacity == 0)
    {
        capacity = std::max(max_demand + 0.01, 6.0 * static_cast<double>(n_vertices) / 4.0);
        std::cout << "Using the Default method to generate capacity constraint" << '\n'
              << "Customer max demand is: " << max_demand << '\n'
              << "Arbitary capacity setting: " << 6.0 * static_cast<double>(n_vertices) / 4.0 << '\n'
              << "Capacity set to " << capacity << '\n';

    } else if ( capacity > 0 && capacity < 1)
    {
        std::cout << "Setting the capacity to " << capacity << " of total demand of all customers"<<'\n'
                  << "Customer max demand is: " << max_demand << '\n'
                  << capacity << " of total demand of all customers is " << total_demand * capacity << '\n';
        capacity = std::max(max_demand+0.01, total_demand * capacity);
        std::cout << "Capacity set to " << capacity << '\n';
    } else
    {
        std::cout << "Setting the capacity to " << capacity <<'\n'
                  << "Customer max demand is: " << max_demand << '\n';
        capacity = std::max(max_demand+0.01, capacity);
        std::cout << "Capacity set to " << capacity << '\n';
    }

    Graph g;

    // The square brackets [] used with boost::graph_bundle in the context of Boost Graph Library (BGL)
    // represent the way to access properties associated with the entire graph, through what's called a property map.
    // boost::graph_bundle is a special key used with property maps when you want to access properties associated with the entire graph, not just individual vertices or edges.
    g.g[boost::graph_bundle] = Instance{capacity};

    for(size_t i = 0u; i < n_vertices; ++i) {
        const bool departing_depot = (i == 0u);// Set to true iff i == 0, this vertex is the first one
        const bool returning_depot = (i == n_vertices - 1u); // Set to true iff i == #vertices-1, this vertex is the last one
        g.vertices[i] = boost::add_vertex(   // (bundled vertex property, the graph you want to add)
                Vertex{departing_depot, returning_depot, demand[i]}, g.g);
    }

    size_t arc_id = 0u;
    for(size_t i = 0u; i < n_vertices - 1u; ++i) {
        for(size_t j = 1u; j < n_vertices; ++j) {
            if(i == j) { continue; } // No self connecting edges

            const auto cost = std::sqrt( // Compute distance as time cost, which is fixed
                    std::pow(xs[i] - xs[j], 2.0) + std::pow(ys[i] - ys[j], 2.0));
            auto [edge, success] = boost::add_edge( // Add edge i to j, with bundled property to the graph g.g
                    g.vertices[i], g.vertices[j], Arc{arc_id++, cost, cost}, g.g);

            assert(success);

            g.arcs[{i, j}] = edge;
            g.costs[{i, j}] = cost;
        }
    }

    return {g, xs, ys};
}


boost::python::tuple generate_random_graph_wrapper(size_t n_customers, unsigned int seed, double capacity) {
    // Call the original function
    auto result = generate_random_graph(n_customers, seed, capacity);

    // Extract elements from the std::tuple
    Graph& graph = std::get<0>(result);
    std::vector<double>& vec1 = std::get<1>(result);
    std::vector<double>& vec2 = std::get<2>(result);

    // Convert to boost::python types
    return boost::python::make_tuple(graph, vec1, vec2);
}
