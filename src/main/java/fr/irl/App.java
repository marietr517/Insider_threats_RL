package fr.irl;

import de.prob.statespace.State;
import java.util.List;

/**
 * Entry point for the simulation application.
 * Initializes the environment and agent, runs episodes,
 * and delegates logging to ExecutionLogger.
 */
public class App {
    public static void main(String[] args) throws Exception {
        // Step 1: Initialize environment and target state
        BankingEnvironment bankingEnv = new BankingEnvironment();
        State maliciousState = bankingEnv.getMaliciousState();
        // Step 2: Create and run the agent
        BankingAgent agent = new BankingAgent(bankingEnv, maliciousState);
        List<List<String>> executedPath = agent.runWithPathWritten();
        // Step 3: Log results to a file
        ExecutionLogger.writeExecutionPathToFile(executedPath, "simulation_output.txt");
        System.exit(0);
    }
}
