package fr.irl;

import java.util.List;

/**
 * Abstract class representing an agent operating in a ProB environment.
 * 
 * This class defines the base interface for any agent that interacts with
 * a given environment. Subclasses must implement both the {@code run()} method
 * for executing the core logic, and {@code runWithPathWritten()} for producing
 * a traceable execution path.
 */
public abstract class Agent {

    /** Reference to the environment in which the agent operates. */
    Environnement environnement;

    /**
     * Constructs an agent with the given environment.
     * 
     * @param environnement the environment in which the agent will operate
     */
    public Agent(Environnement environnement) {
        this.environnement = environnement;
    }

    /**
     * Abstract method to implement the main behavior of the agent.
     * This method allows the agent to run many sessions
     */
    public abstract void run();

    /**
     * Abstract method to run many sessions of the agent,
     * returning the execution traces as a list of actions performed.
     *
     * @return a list of execution paths, each path being a list of actions
     */
    public abstract List<List<String>> runWithPathWritten();
}
