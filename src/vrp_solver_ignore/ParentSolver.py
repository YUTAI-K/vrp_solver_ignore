# This py file defines a parent solver to be inherited to other solvers
from gurobipy import Model, GurobiError, GRB, LinExpr, Column
from typing import List, Dict
from . import cppWrapper


class Parent_Solver:
    def __init__(self, graph: cppWrapper.Graph):
        """
        Initializes the Solver with a given Graph.
        
        Args:
            graph (cppWrapper.Graph): The VRP graph.
        """
        self.graph: cppWrapper.Graph = graph  # C++ Graph object
        self.sp_solver: cppWrapper.ShortestPathSolver = cppWrapper.ShortestPathSolver(self.graph)  # C++ ShortestPathSolver
        # self.routes: List[cppWrapper.Route] = []  # List to store Route objects
        # self.x: List = []  # List to store Gurobi variables
        self.covering: Dict[int, object] = {}  # Mapping from customer vertex to Gurobi constraint

        # Initialize Gurobi model
        try:
            self.model: Model = Model()
            self.model.setParam('OutputFlag', 0)
            self.model.setParam('LogToConsole', 0)
        except GurobiError as e:
            print(f"Cannot start Gurobi: {str(e)}")
            raise

        # Setting up covering constraints
        for v in self.graph.customers():
            constr_name = f"cover_{v}"
            # Add a covering constraint: sum of x[r] where r covers customer v >= 1
            # Initialize the constraint with 0 (no variables yet)
            self.covering[v] = self.model.addConstr(
                LinExpr(),
                GRB.GREATER_EQUAL,
                1.0,
                name=constr_name
            )

        # Initializing columns (variables) pool with Source->v->Sink routes
        for v in self.graph.customers():
            self.add_route(v)

    def add_route(self, v: int) -> None:
        """
        Adds a route to the model. This method handles routes specified by a list of vertices.

        Args:
            vertices (List[int]): A list of vertex IDs representing the route.
        """
        cost = self.graph.cost(self.graph.departing_depot(), v) + self.graph.cost(v, self.graph.returning_depot())
        try:
            # Create a Gurobi variable for this route
            c = Column()
            c.addTerms(1.0, self.covering[v]) # New constraint to add
            var = self.model.addVar(
                lb=0.0,  # Lower bound
                ub=GRB.INFINITY,  # Upper bound
                obj=cost,  # Objective coefficient
                vtype=GRB.CONTINUOUS,  # Variable type
                name=f"0 {v} {self.graph.returning_depot()}({cost})",
                column = c
            )

            # # Add the variable to the list
            # self.x.append(var)
            # self.routes.append(route)
        except GurobiError as e:
            print(f"Error adding route: {str(e)}")
            raise




    def add_route_route(self, route: cppWrapper.Route) -> None:
        """
        Adds a Route object to the model.

        Args:
            route (cppWrapper.Route): The route to add.
        """
        try:
            # Associate the variable with covering constraints
            c = Column()
            vec = []
            for v in route.vertices:
                if v != self.graph.departing_depot() and v != self.graph.returning_depot():
                    # Add coefficient 1.0 to the covering constraint for customer v
                    vec.append(self.covering[v])
            c.addTerms([1.0] * len(vec), vec)
            # Create a Gurobi variable for this route
            var = self.model.addVar(
                lb=0.0,  # Lower bound
                ub=GRB.INFINITY,  # Upper bound
                obj=route.cost,  # Objective coefficient
                vtype=GRB.CONTINUOUS,  # Variable type
                name=str(route),
                column = c
            )


            # # Add the variable to the list
            # self.x.append(var)
            # self.routes.append(route)
        except GurobiError as e:
            print(f"Error adding route: {str(e)}")
            raise
