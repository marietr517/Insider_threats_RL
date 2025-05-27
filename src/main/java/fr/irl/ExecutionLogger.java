package fr.irl;

import java.io.FileWriter;
import java.io.IOException;
import java.util.List;

/**
 * class for logging execution paths of agent episodes.
 * Provides methods to write paths to a file.
 */
public class ExecutionLogger {

    /**
     * Writes the execution paths to a file.
     * 
     * @param executedPath List of episode paths (each is a list of string steps)
     * @param filename Name of the output file
     */
    public static void writeExecutionPathToFile(List<List<String>> executedPath, String filename) {
        try (FileWriter writer = new FileWriter(filename)) {
            int pathIndex = 1;
            for (List<String> path : executedPath) {
                writer.write("Execution Path " + pathIndex + ":\n");
                int stepCounter = 1;
                for (String step : path) {
                    writer.write("Step " + stepCounter + ": " + step + "\n");
                    stepCounter++;
                }
                writer.write("\n");
                pathIndex++;
            }
            System.out.println("Execution path written to " + filename);
        } catch (IOException e) {
            System.err.println("Error writing execution path: " + e.getMessage());
        }
    }
}
