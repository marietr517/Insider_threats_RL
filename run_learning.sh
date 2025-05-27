#!/bin/bash
echo "Compilation du projet..."
mvn clean compile
echo -e "\nLancement de 20 runs... Ça prend du temps !\n"
extract_or_default() {
    local pattern="$1"
    local unit="$2"
    local line
    line=$(echo "$output" | grep "$pattern" | tail -1)
    if [[ -z "$line" ]]; then
        echo "?"
    else
        echo "$line" | sed "s/.*: //;s/ $unit//"
    fi
}
printf "%-5s | %-10s | %-15s | %-15s | %-15s\n" \
       "Run" "Time(s)" "NB states" "Length path" "Evaluations"
echo "------------------------------------------------------------------------------------"

for i in $(seq 1 20); do
    output=$(mvn exec:java -Dexec.mainClass="TON.PACKAGE.MainClass" 2>&1 | grep -v "WARNING:")

    duree=$(extract_or_default "Time consumed in the learning process" "s")
    etats=$(extract_or_default "Nb of visited states" "")
    chemin=$(extract_or_default "Length of lastpath" "")
    evals=$(extract_or_default "Nb of evaluations" "")

    printf "%-5s | %-10s | %-15s | %-15s | %-15s\n" \
           "$i" "$duree" "$etats" "$chemin" "$evals"
done
