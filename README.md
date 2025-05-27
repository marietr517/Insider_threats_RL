# Internal Attack Detection with Reinforcement Learning

This project is part of an **IRL research initiative** developed at Ensimag/Verimag lab. It aims to detect internal attacks within systems modeled using the **B method**. The system's formal behavior is explored using the **ProB model checker** and a **Q-learning reinforcement learning agent** to identify malicious state transitions.

---

## Project Overview

* **Goal**: Automatically detect and reach malicious states in a B-modeled RBAC (Role-Based Access Control) system.
* **Environment**: Java, Maven, ProB2 Kernel.
* **Approach**:
  * Use ProB to simulate the behavior of a secure RBAC system.
  * Represent the environment as a state space.
  * Train a reinforcement learning agent (Q-learning) to explore the state space and identify attack paths.

---


## Requirements

* Java 11+
* Maven 3+
* ProB2 Kernel (included via Maven dependency)

---

## How to Run

```bash
# Clean and compile the project
mvn clean compile

# Run one training session
mvn exec:java

# Run the agent 20 times 
chmod +x run_learning.sh
./run_learning.sh
```
---


## Contact

**Triki Mariem**
Ensimag 2A 

mariem.triki@grenoble-inp.org

---

