package fr.irl;

import java.util.*;


public final class ComputeDistance {

    /**
     * Compute a 'distance' between the initial state and final state,
     * it parses the string to see if it's a set, map, int, boolean, or plain string and computes
     * the distance according to the type 
     */
    public static double computeDistance(Map<String, String> aVars, Map<String, String> bVars) {
     
        Set<String> allKeys = new HashSet<>(aVars.keySet());
        allKeys.addAll(bVars.keySet());

        double weightedSum = 0.0;
        double totalWeights = 0.0;

        Map<String, Double> WEIGHTS = new HashMap<>();
        WEIGHTS.put("Account", 1.0);
        WEIGHTS.put("Customer", 1.0);
        WEIGHTS.put("AccountOwner", 1.0);
        // we keep only 3 variables so that we can compare with the same results obtained 
        //in the antcolony program
        //WEIGHTS.put("CreditCardOwner", 0.0);
        //WEIGHTS.put("Account__balance", 0.05); 
        //WEIGHTS.put("Account__IBAN", 0.05); 
        //WEIGHTS.put("Account__overdraft", 0.05); 
        for (String key : allKeys) {
            String valA = aVars.get(key);
            String valB = bVars.get(key);
            double w = WEIGHTS.getOrDefault(key, 1.0);
            weightedSum += w * distanceForVariable(parseValue(valA), parseValue(valB));
            totalWeights += w;
        }

        if (totalWeights == 0.0) return 0.0;
        return weightedSum / totalWeights;
    }

    /**
     * Interprets a string value =>  a Set<String>, a Map<String,String>,
     * an Integer, a Boolean, or just a string.
     */
    private static Object parseValue(String str) {
        if (str == null) return null;
        // ex. {Paul,Bob,Martin} => set
        if (str.matches("\\{.*\\}") && !str.contains("↦")) {
            return parseSet(str);
        }
        // ex. {(cpt1↦Bob),(cpt2↦Martin)} => map
        if (str.matches("\\{.*↦.*\\}")) {
            return parseRelation(str);
        }
        // ex. 123 or -100 => int
        if (str.matches("-?\\d+")) {
            return Integer.parseInt(str);
        }
        // ex. TRUE/FALSE => bool
        if (str.equalsIgnoreCase("TRUE") || str.equalsIgnoreCase("FALSE")) {
            return Boolean.parseBoolean(str);
        }
        // ex. ∅ => empty set
        if (str.equals("∅")) {
            return Collections.emptySet();
        }
        return str;
    }

    private static Set<String> parseSet(String val) {
        String inner = val.replaceAll("[\\{\\}]", "").trim();
        if (inner.isEmpty()) return new HashSet<>();
        String[] elements = inner.split(",");
        Set<String> result = new HashSet<>();
        for (String e : elements) {
            result.add(e.trim());
        }
        return result;
    }

    private static Map<String, String> parseRelation(String val) {
        // ex: {(cpt1↦Bob),(cpt2↦Martin)}
        String inner = val.replaceAll("[\\{\\}]", "").trim();
        Map<String, String> result = new HashMap<>();
        String[] pairs = inner.split("\\),");
        for (String p : pairs) {
            p = p.replaceAll("[()]", "").trim();
            String[] kv = p.split("↦");
            if (kv.length == 2) {
                result.put(kv[0].trim(), kv[1].trim());
            }
        }
        return result;
    }

    /**
     * Partial distance based on the parsed types: sets => jaccard, map => mapDistance, int => intDistance, etc.
     */
    private static double distanceForVariable(Object valA, Object valB) {
        if (valA == null && valB == null) return 0.0;
        if (valA == null || valB == null) return 1.0;

        if (valA instanceof Set && valB instanceof Set) {
            return jaccardDistance((Set<String>) valA, (Set<String>) valB);
        }
        if (valA instanceof Map && valB instanceof Map) {
            return mapDistance((Map<String,String>) valA, (Map<String,String>) valB);
        }
        if (valA instanceof Integer && valB instanceof Integer) {
            return intDistance((Integer) valA, (Integer) valB);
        }
        if (valA instanceof Boolean && valB instanceof Boolean) {
            return valA.equals(valB) ? 0.0 : 1.0;
        }
        // default => compare strings
        return valA.equals(valB) ? 0.0 : 1.0;
    }

    private static double jaccardDistance(Set<String> sA, Set<String> sB) {
        if (sA.isEmpty() && sB.isEmpty()) {
            return 0.0;
        }
        Set<String> union = new HashSet<>(sA);
        union.addAll(sB);
        Set<String> inter = new HashSet<>(sA);
        inter.retainAll(sB);
        return 1.0 - (inter.size() / (double) union.size());
    }

    private static double mapDistance(Map<String, String> mA, Map<String, String> mB) {
        Set<String> allKeys = new HashSet<>(mA.keySet());
        allKeys.addAll(mB.keySet());
        if (allKeys.isEmpty()) return 0.0;

        double diffSum = 0.0;
        for (String k : allKeys) {
            String va = mA.get(k);
            String vb = mB.get(k);
            diffSum += distancePerKey(va, vb);
        }
        return diffSum / allKeys.size();
    }

    private static double distancePerKey(String va, String vb) {
        if (va == null && vb == null) return 0.0;
        if (va == null || vb == null ) return 1.0;
        
        // try parse int
        Integer iA = tryParseInt(va);
        Integer iB = tryParseInt(vb);
        if (iA != null && iB != null) {
            return intDistance(iA, iB);
        }
        // else compare strings
        return va.equals(vb) ? 0.0 : 1.0;
    }

    private static Integer tryParseInt(String s) {
        try {
            return Integer.valueOf(s);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static double intDistance(int iA, int iB) {
        int diff = Math.abs(iA - iB);
        double normalized = diff / 1000.0;
        return (normalized > 1.0) ? 1.0 : normalized;
    }
    /**
     * Alternative scoring method using .
     */
    public static double computeDistance_2(Map<String, String> current, Map<String, String> target) {
        Map<String, Double> WEIGHTS = new HashMap<>();
        WEIGHTS.put("Account", 1.0);
        WEIGHTS.put("Customer", 1.0);
        WEIGHTS.put("AccountOwner", 1.0);
        //WEIGHTS.put("CreditCardOwner", 0.0); //in this example we don't use credit card yet 
        //WEIGHTS.put("Account__balance", 0.05); //not important var 
        //WEIGHTS.put("Account__IBAN", 0.05); //not important var 
        //WEIGHTS.put("Account__overdraft", 0.05); //not important var 
        double score = 0.0;
        double totalWeight = 0.0;
        for (Map.Entry<String, String> entry : target.entrySet()) {
            String key = entry.getKey();
            String valTarget = entry.getValue();
            String valCurrent = current.get(key);
            Object parsedTarget = parseValue(entry.getValue());
            Object parsedCurrent = parseValue(valCurrent);
            double weight = WEIGHTS.getOrDefault(key, 1.0);
            if (parsedTarget instanceof Set) {
                Set<String> setTarget = (Set<String>) parsedTarget;
                Set<String> setCurrent = parsedCurrent instanceof Set ? (Set<String>) parsedCurrent : new HashSet<>();
                double localWeight = weight / setTarget.size();
                for (String elem : setTarget) {
                    score += setCurrent.contains(elem) ? localWeight : 0;
                    totalWeight += localWeight;
                }
            } else if (parsedTarget instanceof Map) {
                Map<String, String> mapTarget = (Map<String, String>) parsedTarget;
                Map<String, String> mapCurrent = parsedCurrent instanceof Map ? (Map<String, String>) parsedCurrent : new HashMap<>();
                double localWeight = weight / mapTarget.size();
                for (Map.Entry<String, String> pair : mapTarget.entrySet()) {
                    String k = pair.getKey();
                    String expectedVal = pair.getValue();
                    String actualVal = mapCurrent.get(k);
                    score += expectedVal.equals(actualVal) ? localWeight : 0;
                    totalWeight += localWeight;
                }
            } else {
                score += valTarget.equals(valCurrent) ? weight : 0;
                totalWeight += weight;
            }
        }
        if (totalWeight == 0) return 1.0;
        return 1.0 - score / totalWeight;
    }
    
}
