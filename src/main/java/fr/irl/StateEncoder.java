package fr.irl;
import de.prob.statespace.State;
import java.util.*;

/**
 * Utility class to extract and encode state variables from a B-machine state.
 */
public class StateEncoder {

    /** List of B variables to consider. */
    private static final String[] abstractVars = {
        "Account", "Customer", "AccountOwner","Session"
    };
 
    /**
     * Extracts variables from the B-machine's  as strings only.
     */
    public static Map<String, String> extractStateVars(State state) {
        Map<String, String> vars = new HashMap<>();

        for (String var : abstractVars) {
            String valuevar = state.eval(var).toString();
            vars.put(var, valuevar);
        }
        return vars;
    }
    /*state Account={cpt1,cpt2};AccountOwner={(cpt1↦Paul),(cpt2↦Martin)};Account__IBAN={(cpt1↦111),(cpt2↦222)};
    Account__balance={(cpt1↦300),(cpt2↦-100)};Account__overdraft={(cpt1↦-100),(cpt2↦-100)};CreditCard=∅;CreditCardOwner=∅;Customer={Paul,Martin};Session=∅;*/
    /*function that genreates a string to encode the state from its variables values  */
    public static String encodeState(Map<String, String> vars) {
        // Sort keys for consistency
        List<String> sortedKeys = new ArrayList<>(vars.keySet());
        Collections.sort(sortedKeys);
        StringBuilder sb = new StringBuilder();
        for (String key : sortedKeys) {
            String val = vars.get(key);
            sb.append(key).append("=").append(val).append(";");
        }
        return sb.toString();
    }
   
}
