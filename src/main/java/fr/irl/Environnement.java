package fr.irl;

import de.prob.statespace.State;
import de.prob.statespace.StateSpace;
import de.prob.statespace.Transition;

/**
 * Abstract class representing a ProB-based environment that loads a B-machine,
 * handles its state transitions, and interacts with its state space.
 * 
 * This class provides utility methods to explore, initialize, and run transitions
 * within a given B model using the ProB Java API.
 */
public abstract class Environnement {

    /** Animator interface to interact with the B-machine through ProB. */
    protected MyProb animator = MyProb.INJECTOR.getInstance(MyProb.class);

    /** Initial state of the machine after setup and initialization. */
    private State initial;

    /** Current state of the environment during exploration. */
    private State state;

    /**
     * Constructs a new environment by loading the given B-machine file.
     * 
     * @param filePath the file path to the B-machine (.mch) to load
     */
    public Environnement(String filePath) {
        try {
            animator.load(filePath);
        } catch (Exception e) {
            e.printStackTrace();
        }
        this.initial = animator.getStateSpace().getRoot();
    }

    /**
     * Initializes the B-machine by executing SETUP_CONSTANTS and INITIALISE_MACHINE transitions,
     * then explores the resulting initial state.
     */
    public void initialise() {
        Transition setup = initial.findTransition(Transition.SETUP_CONSTANTS_NAME);
        if (setup != null) {
            initial = setup.getDestination();
        }

        Transition initialisation = initial.findTransition(Transition.INITIALISE_MACHINE_NAME);
        if (initialisation != null) {
            initial = initialisation.getDestination();
        }

        this.state = initial.exploreIfNeeded();
    }

    /**
     * Returns the current state of the environment.
     * 
     * @return the current state
     */
    public State getState() {
        return this.state;
    }

    /**
     * Sets the current state of the environment.
     * 
     * @param state the state to set as current
     */
    public void setState(State state) {
        this.state = state;
    }

    /**
     * Returns the initial state of the environment.
     * 
     * @return the initial state
     */
    public State getInitialState() {
        return this.initial;
    }

    /**
     * Returns the StateSpace object associated with the loaded machine.
     * 
     * @return the state space
     */
    public StateSpace getStateSpace() {
        return this.animator.getStateSpace();
    }

    /**
     * Executes a given transition and sets the destination as the current state.
     * 
     * @param t the transition to execute
     * @return the resulting state after execution
     */
    public State runAction(Transition t) {
        this.state = t.getDestination().explore();
        return this.state;
    }

    /**
     * Executes any available operation from a given state and sets the result as the current state.
     * 
     * @param inputState the state from which to perform an arbitrary transition
     * @return the resulting state
     */
    public State runAnyAction(State inputState) {
        this.state = inputState.anyOperation(null).explore();
        return this.state;
    }

    /**
     * Executes a specific named action with optional parameters.
     * 
     * @param actionName the name of the action to perform
     * @param actionPredicate optional parameters to the action
     */
    public void runAction(String actionName, String... actionPredicate) {
        this.state = state.perform(actionName, actionPredicate).explore();
    }

    /**
     * Displays detailed information about a transition, including its source and destination states.
     * 
     * @param t the transition to display
     */
    public void showTransition(Transition t) {
        System.out.println("\nTransition : " + t.getId() + " - " + t.getName() + "[" + t.getParameterPredicate() + "]");
        System.out.println("\nSource : ");
        animator.printState(t.getSource());
        System.out.println("\nDestination : ");
        animator.printState(t.getDestination());
    }

    /**
     * Displays a specific state using the animator's print function.
     * 
     * @param state the state to print
     */
    public void printState(State state) {
        animator.printState(state);
    }
}
