package fr.irl;
import de.prob.statespace.State;
import de.prob.statespace.Transition;
import java.util.*;

/**
 * A Q-learning based agent exploring transitions to approach a malicious state.
 * The malicious state is known, and we measure 'distance' to it by comparing
 * relevant variables in a B-machine model (like AccountOwner, balance, etc.).
 */
public class BankingAgent extends Agent {
    private QTable Qtable=new QTable();
    private double alpha = 0.1;
    private double gamma = 0.97;
    private double epsilon;
    private final Random rand = new Random();
    private int maxActions = 40;
    private final double seuil = 0.005;  // distance threshold needs to be adjusted according to the distance being used 
    private final Map<String, String> maliciousVars; 
    //performance tools 
    private long startTimeMs;
    private long endTimeMs;
    private int evalCount = 0;
    /**
     * Constructor for the agent.
     * @param env the environment in which the agent operates
     * @param maliciousState the known malicious state (goal)
     */
    public BankingAgent(Environnement env, State maliciousState) {
        super(env);
        this.maliciousVars = StateEncoder.extractStateVars(maliciousState);
    }
    /** Basic run loop for testing. */
    @Override
    public void run() {
        for (int episode = 0; episode < 1000; episode++) {
            executeEpisode(episode);
        }
    }
    /**
     * Main method for running training and recording the sequence of actions taken.
     * @return a list of all action paths taken during episodes
     */
    public List<List<String>> runWithPathWritten() {
        startTimeMs = System.currentTimeMillis(); 
        List<List<String>> executedPaths = new ArrayList<>();
        // Phase 1: exploration high
        epsilon = 0.7;
        for (int episode = 0; episode <70; episode++) {
            adjustEpsilon(episode);
            List<String> episodePath = executeEpisode(episode);
            executedPaths.add(episodePath);
        }
        // Phase 2: higher exploitation reduce epsilon, increase gamma
        epsilon = 0.05;
        gamma = 0.99;
        endTimeMs = System.currentTimeMillis();
        for (int episode = 0; episode < 5; episode++) {
            List<String> episodePath = executeEpisode(episode);
            executedPaths.add(episodePath);
        }
        // Summary
        int totalStatesVisited = Qtable.getTable().size();
        List<String> lastPath = executedPaths.get(executedPaths.size() - 1);
        System.out.println("\n--- learning process ---");
        System.out.println("Time consumed in the learning process : " + ((endTimeMs - startTimeMs)/1000) + " s");
        System.out.println("Nb of visited states : " + totalStatesVisited);
        System.out.println("Length of lastpath : " + lastPath.size());
        System.out.println("Nb of evaluations : " + evalCount);

        return executedPaths;
    }

    /* Adjusts the maximum number of actions allowed depending on episode. */
    private void adjustMaxActions(int episode) {
        if (episode > 50) {
            maxActions = 30;
        } else if (episode > 40) {
            maxActions = 40;
        } else if (episode > 20) {
            maxActions = 50;
        } else {
            maxActions = 60;
        }
    }
    /* Adjusts the epsilon value dynamically over episodes. */
    private void adjustEpsilon(int episode) {
        if (episode > 50) {
            epsilon=0.2;
        } else if (episode > 40) {
           epsilon=0.3;
        } else if (episode > 20) {
            epsilon=0.4;
        } else {
            epsilon=0.7;
        }
    }
    /**
     * Executes one episode of learning (a sequence of actions from initial state).
     * @param episode episode index
     * @return list of strings showing each step taken
     */
    private List<String> executeEpisode(int episode) {
        List<String> episodePath = new ArrayList<>();
        this.environnement.initialise();
        State current = this.environnement.getState().perform("setPermissions");
        current = current.perform("secure_InitiateAttack");
        State currentProbState = current;
        int actionCount = 0;
        double dist = 5.0;
        Map<String, String> currentVars = StateEncoder.extractStateVars(currentProbState);
        //printHashMap(currentVars);
        //printHashMap(maliciousVars);
        String currentStateID = StateEncoder.encodeState(currentVars);
        //System.out.println("state " +currentStateID );
        while (!currentProbState.getOutTransitions().isEmpty()
                && dist > seuil
                && actionCount < maxActions) {

            // List possible transitions
            List<Transition> actions = currentProbState.getOutTransitions();
            Transition chosenActiont = chooseAction(currentStateID, actions);
            String chosenAction = buildActionKey(chosenActiont);
            // Execute the chosen action
            this.environnement.runAction(chosenActiont);
            State nextProbState = this.environnement.getState();
            // Evaluate next state
            Map<String, String> nextVars = StateEncoder.extractStateVars(nextProbState);
            String nextStateID = StateEncoder.encodeState(nextVars);
            //Transition nextChosenActionT = chooseAction(nextStateID, nextProbState.getOutTransitions());
            //String nextAction = buildActionKey(nextChosenActionT);
            // measure distance to malicious state 
            dist = ComputeDistance.computeDistance_2(nextVars, maliciousVars);
            evalCount++;
            double currdist = ComputeDistance.computeDistance_2(currentVars, maliciousVars);
            double reward = computeReward(dist, currdist);
            // Q-table update
            // using qlearning 
            Qtable.updateQTable(currentStateID, chosenAction, reward, nextStateID, alpha,gamma);
            //using sarsa 
            //Qtable.updateSarsa(currentStateID, chosenAction, reward, nextStateID, nextAction, alpha, gamma);
            episodePath.add(" -> Action: " + chosenAction + " -> Reward: " + reward);
            currentProbState = nextProbState;
            currentStateID = nextStateID;
            currentVars = nextVars;
            actionCount++;
            if (dist == 0.0) {
                //System.out.println("objectif atteint episode num " + episode);
                break;
            }
            adjustMaxActions(episode);
        }
        System.out.println("distance " + dist);
        System.out.println("step " + actionCount);
        System.out.println("episode " + episode);
        return episodePath;
    }

    /**
     * Basic reward function based on how the distance evolves
     */
    private double computeReward(double dist, double currdist) {
        if (dist > currdist) {
            // we went further from malicious => negative
            return -50.0 * (dist - currdist) + (-10 * (1 - dist));
        } else if (dist == currdist) {
            return -1.9;
        } else {
            // we got closer => positive
            double reward = 50.0 * (currdist - dist) + (10 * (1 - dist));
            if (dist < 0.05) {
                reward += 20.0; //bonus
            }
            return reward;
        }
    }
     
    /**
     * Choose an action via epsilon-greedy policy.
     */
    private Transition chooseAction(String state, List<Transition> actions) {
        Transition selectedAction = null;
        // Epsilon => exploration
        if (rand.nextDouble() < epsilon) {
            // Filter out some actions we need to avoid
            List<Transition> filtered = new ArrayList<>();
            for (Transition t : actions) {
                String actionName = t.getName();
                if (!actionName.equals("LaunchAttack") && !actionName.equals("secure_InitiateAttack")) {
                    filtered.add(t);
                }
            }
            if (!filtered.isEmpty()) {
                selectedAction = filtered.get(rand.nextInt(filtered.size()));
            }
        } else {
            // Exploitation
            double bestQ = Double.NEGATIVE_INFINITY;
            for (Transition t : actions) {
                String name = t.getName();
                if (name.equals("LaunchAttack") || name.equals("secure_InitiateAttack")) {
                    continue;
                }
                String aKey = buildActionKey(t);
                double q = Qtable.getTable().getOrDefault(state, new HashMap<>()).getOrDefault(aKey, 0.0);
                if (q > bestQ) {
                    bestQ = q;
                    selectedAction = t;
                }
            }
        }
        // pick random
        if (selectedAction == null && !actions.isEmpty()) {
            selectedAction = actions.get(rand.nextInt(actions.size()));
        }

        return selectedAction;
    }
    
    /**
     * Build a unique action key = ActionName + (ParameterPredicate)
     */
    private String buildActionKey(Transition t) {
        String baseName = t.getName();
        String paramPred = t.getParameterPredicate().trim();
        return paramPred.isEmpty() ? baseName : baseName + "(" + paramPred + ")";
    }
    // Debug method if you want to see the content of the map encoding the state 
    public void printHashMap(Map<String, String> map) {
        // This only prints var-> stringValue
        System.out.println("== State Variables ==");
        for (Map.Entry<String, String> e : map.entrySet()) {
            System.out.println(e.getKey() + " -> " + e.getValue());
        }
    }
} 

