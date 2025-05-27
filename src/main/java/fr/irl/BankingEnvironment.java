    package fr.irl;
    import de.prob.statespace.State;
    /**
     * BankingEnvironment is a specialized environment (The Bank) for interacting with the 
     * B machine model "RBAC_Model.mch", representing a role-based access control system.
     * 
     */
    
    public class BankingEnvironment extends Environnement {
         /**
         * Constructs a new BankingEnvironment that loads the RBAC_Model machine
         * and initializes it to a starting state.
         */
        public BankingEnvironment() {
            super("/Machines_B/RBAC_Model.mch");
            this.initialise();
        }
            /**
         * Defines and returns the target "malicious state" of the RBAC system.
         *
         * This state represents the outcome of a successful internal attack,
         * which the agent will attempt to reach by exploring transitions from
         * the initial system configuration.The variables of this state are defined in Functional.mch
         *
         * The resulting malicious state is stored and will serve as a goal for the agent,
         * which will attempt to reconstruct a valid path (trace of events)
         * that leads from the initial state to this compromised one.
         *
         * @return the target malicious state that represents the result of the simulated attack.
         */
    
         public State getMaliciousState() {
            State init = this.getState();
        
            // Execute setPermissions
            State second = init.perform("setPermissions");
            System.out.println("After setPermissions: " + second.getId());
        
            // Launch an attack if available
            State malicious = second.perform("LaunchAttack");
            // set the session
            malicious = malicious.perform("Connect", "user=Bob", "roleSet={AccountManager}");
        
            this.initialise(); // Reinitialize the environment
        
            return malicious;
        }
    }        
    
    
        