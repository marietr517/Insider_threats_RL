package fr.irl;

import java.util.*;

/**
 * Class that encapsulates a Q-table for Q-learning and SARSA algorithms.
 * The Q-table is implemented as a nested map: Map<State, Map<Action, Q-value>>.
 * 
 */
public class QTable {
     /** Q-table structure: maps each state to its available actions and their Q-values */
    private Map<String, Map<String, Double>> Qtable = new HashMap<>();
    public Map<String, Map<String, Double>> getTable(){
        return Qtable;
    }
    /**
     * Updates the Q-table using the Q-learning update rule:
     *     Q(s, a) ← Q(s, a) + α [r + γ * max_a' Q(s', a') − Q(s, a)]
     *
     * @param state Current state (s)
     * @param action Action taken (a)
     * @param reward Reward received after the action (r)
     * @param nextState Next state reached after the action (s')
     * @param alpha Learning rate (α)
     * @param gamma Discount factor (γ)
     */
    public void updateQTable(String state, String action, double reward, String nextState,double alpha,double gamma) {
        Qtable.putIfAbsent(state, new HashMap<>());
        double oldQ = Qtable.get(state).getOrDefault(action, 0.0);
        double maxNextQ = getMaxQValue(nextState);
        double newQ = oldQ + alpha * (reward + gamma * maxNextQ - oldQ);
        Qtable.get(state).put(action, newQ);
    }
    /**
     * Updates the Q-table using the SARSA update rule:
     *     Q(s, a) ← Q(s, a) + α [r + γ * Q(s', a') − Q(s, a)]
     *
     * @param state Current state (s)
     * @param action Action taken (a)
     * @param reward Reward received (r)
     * @param nextState Next state (s')
     * @param nextAction Next action to be taken in s' (a')
     * @param alpha Learning rate (α)
     * @param gamma Discount factor (γ)
     */
    public void updateSarsa(String state, String action, double reward, String nextState, String nextAction, double alpha, double gamma) {
        Qtable.putIfAbsent(state, new HashMap<>());
        Qtable.putIfAbsent(nextState, new HashMap<>());
        double oldQ = Qtable.get(state).getOrDefault(action, 0.0);
        double nextQ = Qtable.get(nextState).getOrDefault(nextAction, 0.0);
        double newQ = oldQ + alpha * (reward + gamma * nextQ - oldQ);
        Qtable.get(state).put(action, newQ);
    }
    
    /**
     * Retrieves the highest Q-value for a given state.
     *
     * @param state State whose best Q-value is queried.
     * @return The maximum Q-value for the state, or 0.0 if no actions exist.
     */
    public double getMaxQValue(String state) {
        Map<String, Double> actionMap = Qtable.get(state);
        if (actionMap == null || actionMap.isEmpty()) {
            return 0.0;
        }
        return Collections.max(actionMap.values());
    }
    /**
     * Pretty-print the entire Q-table to the console.
     * Each state is listed with its available actions and their Q-values.
     */
    public void printQTable() {
        System.out.println("\n Q-Table");
        if (Qtable.isEmpty()) {
            System.out.println("the Q-Table is empty !");
            return;
        }
        for (Map.Entry<String, Map<String, Double>> Entry : Qtable.entrySet()) {
            String state =Entry.getKey();
            Map<String, Double> actions = Entry.getValue();
            System.out.println("\nÉtat : " + state);
            if (actions.isEmpty()) {
                System.out.println("  (no actions)");
            } else {
                for (Map.Entry<String, Double> action : actions.entrySet()) {
                    System.out.printf("  Action: %s | Q-Value: %.3f\n", action.getKey(), action.getValue());
                }
            }
        }
    }


}
