#include "library.h"
#include <iostream>
#include "Graph.h"
#include <random>
#include <fstream>
#include <sstream>
#include "Route.h"
#include "ShortestPath.h"

// Boost.Python headers
#include <boost/python.hpp>
#include <boost/python/suite/indexing/vector_indexing_suite.hpp>


namespace bp = boost::python;

// Converter from Python dict to std::map<unsigned long, double>
struct DictToMapULDConverter {
    DictToMapULDConverter() {
        bp::converter::registry::push_back(&convertible, &construct, bp::type_id<std::map<unsigned long, double>>());
    }

    // Check if the Python object can be converted
    static void* convertible(PyObject* obj_ptr) {
        if (!PyDict_Check(obj_ptr)) return nullptr;
        return obj_ptr;
    }

    // Convert the Python dict to std::map<unsigned long, double>
    static void construct(PyObject* obj_ptr, bp::converter::rvalue_from_python_stage1_data* data) {


        // Allocate storage for the C++ map
        void* storage = ((bp::converter::rvalue_from_python_storage<std::map<unsigned long, double>>*)data)->storage.bytes;
        new (storage) std::map<unsigned long, double>();

        std::map<unsigned long, double>* m = (std::map<unsigned long, double>*)storage;

        // Iterate through the Python dict
        PyObject *key, *value;
        Py_ssize_t pos = 0;

        while (PyDict_Next(obj_ptr, &pos, &key, &value)) {
            // Extract key as unsigned long
            if (!PyLong_Check(key)) {
                PyErr_SetString(PyExc_TypeError, "Keys must be integers (unsigned long)");
                bp::throw_error_already_set();
            }
            unsigned long k = PyLong_AsUnsignedLong(key);
            if (k == (unsigned long)-1 && PyErr_Occurred()) {
                bp::throw_error_already_set();
            }

            // Extract value as double
            if (!PyFloat_Check(value) && !PyLong_Check(value)) {
                PyErr_SetString(PyExc_TypeError, "Values must be floats or integers (double)");
                bp::throw_error_already_set();
            }
            double v = PyFloat_AsDouble(value);
            if (v == -1.0 && PyErr_Occurred()) {
                bp::throw_error_already_set();
            }

            // Insert into the map
            (*m)[k] = v;
        }

        data->convertible = storage;
    }
};

BOOST_PYTHON_MODULE(cppWrapper)
{

    // Register the converter
    DictToMapULDConverter();
    // Initialize Boost.Python
    Py_Initialize();

    // Expose std::vector<int>
    bp::class_<std::vector<int> >("IntVector")
        .def(bp::vector_indexing_suite<std::vector<int> >());

    // Expose std::vector<double>
    bp::class_<std::vector<double> >("DoubleVector")
        .def(bp::vector_indexing_suite<std::vector<double> >());

    // Expose std::vector<size_t>
    bp::class_<std::vector<size_t> >("SizeTVector")
        .def(bp::vector_indexing_suite<std::vector<size_t> >());

    // Expose std::vector<BoostVertex>
    bp::class_<std::vector<BoostVertex> >("BoostVerticesVector")
        .def(bp::vector_indexing_suite<std::vector<BoostVertex> >());

    // Expose Vertex
    bp::class_<Vertex>("Vertex", bp::no_init)
        .def_readwrite("departing_depot", &Vertex::departing_depot)
        .def_readwrite("returning_depot", &Vertex::returning_depot)
        .def_readwrite("demand", &Vertex::demand)
    ;

    // Expose Arc
    bp::class_<Arc>("Arc", bp::no_init)
        .def_readwrite("id", &Arc::id)
        .def_readwrite("cost", &Arc::cost)
        .def_readwrite("original_cost", &Arc::original_cost)
    ;

    // Expose Instance
    bp::class_<Instance>("Instance", bp::no_init)
        .def_readwrite("capacity", &Instance::capacity)
    ;

    // Expose Graph
    bp::class_<Graph>("Graph", bp::no_init)
        .def("n_vertices", &Graph::n_vertices)
        .def("n_customers", &Graph::n_customers)
        .def("departing_depot", &Graph::departing_depot)
        .def("returning_depot", &Graph::returning_depot)
        .def("customers", &Graph::customers)
        .def("capacity", &Graph::capacity)
        .def("demand", &Graph::demand)
        .def("cost", &Graph::cost)
    ;

    // Expose Route
    bp::class_<Route>("Route", bp::no_init)
        .def(bp::init<std::vector<BoostVertex>, double>()) // Constructor 1
        .def(bp::init<std::vector<size_t>, const BoostGraph&>()) // Constructor 2
        .def_readwrite("vertices", &Route::vertices)
        .def_readwrite("cost", &Route::cost)
        .def("__str__", +[](const Route &r) -> std::string {
            std::ostringstream out;
            out << r; // Uses the overloaded operator<<
            return out.str();
        })
    ;

    // Expose std::vector<Route>
    bp::class_<std::vector<Route> >("RouteVector")
        .def(bp::vector_indexing_suite<std::vector<Route> >());

    // Expose ShortestPathSolver
    bp::class_<ShortestPathSolver>("ShortestPathSolver", bp::no_init)
        .def(bp::init<Graph&>())
        .def("solve_shortest_path", &ShortestPathSolver::solve_shortest_path)
        .def("solve_incremental_shortest_path", &ShortestPathSolver::solve_incremental_shortest_path)
        .def("solve_incremental_k_best_shortest_path", &ShortestPathSolver::solve_incremental_k_best_shortest_path)
        .def("solve_ignoring_incremental_shortest_path", &ShortestPathSolver::solve_ignoring_incremental_shortest_path)
        .def("solve_ignoring_incremental_multiplicity_shortest_path", &ShortestPathSolver::solve_ignoring_incremental_multiplicity_shortest_path)
        .def("solve_ignoring_shortest_path", &ShortestPathSolver::solve_ignoring_shortest_path)
    ;

    // Expose functions
    bp::def("generate_random_graph", &generate_random_graph_wrapper, "Generate a random VRP graph");
}
