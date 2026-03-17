### Task 1 — Git State Reconciliation (6 pts)

#### 1.1: Setup Desired State Configuration

1. **Create Desired State (Source of Truth):**

   ```bash
   echo "version: 1.0" > desired-state.txt
   echo "app: myapp" >> desired-state.txt
   echo "replicas: 3" >> desired-state.txt
   ```

2. **Simulate Current Cluster State:**

   ```bash
   cp desired-state.txt current-state.txt
   echo "Initial state synchronized"
   ```
Output: `Initial state synchronized`


#### 1.2: Create Reconciliation Loop

1. **Create Reconciliation Script:**

   ```bash
   cat > reconcile.sh <<'EOF'
    #!/bin/bash
    # reconcile.sh - GitOps reconciliation loop
    
    DESIRED=$(cat desired-state.txt)
    CURRENT=$(cat current-state.txt)
    
    if [ "$DESIRED" != "$CURRENT" ]; then
        echo "$(date) - DRIFT DETECTED!"
        echo "Reconciling current state with desired state..."
        cp desired-state.txt current-state.txt
        echo "$(date) - Reconciliation complete"
    else
        echo "$(date) - States synchronized"
    fi
    EOF

   ```

2. **Make Script Executable:**

   ```bash
   chmod +x reconcile.sh
   ./reconcile.sh
   ```
   
Output: `среда, 18 марта 2026 г. 01:37:52 (MSK) - States synchronized`

#### 1.3: Test Manual Drift Detection

1. **Simulate Manual Drift:**

   ```bash
   echo "version: 2.0" > current-state.txt
   echo "app: myapp" >> current-state.txt
   echo "replicas: 5" >> current-state.txt
   ```

2. **Run Reconciliation Manually:**

   ```bash
   ./reconcile.sh
   diff desired-state.txt current-state.txt
   ```
   
Output: 
```bash
среда, 18 марта 2026 г. 01:38:25 (MSK) - DRIFT DETECTED!
Reconciling current state with desired state...
среда, 18 марта 2026 г. 01:38:25 (MSK) - Reconciliation complete
```

3. **Verify Drift Was Fixed:**

   ```bash
   cat current-state.txt
   ```
   
Output: 
```bash
version: 1.0
app: myapp
replicas: 3
```

#### 1.4: Automated Continuous Reconciliation

1. **Start Continuous Reconciliation Loop:**

   ```bash
   watch -n 5 ./reconcile.sh
   ```
![watch output 1](watch_-n_5_(1).png)



2. **In Another Terminal, Trigger Drift:**

   ```bash
   cd gitops-lab
   echo "replicas: 10" >> current-state.txt
   ```
![watch output 2](watch_-n_5_(2).png)

3. **Observe Auto-Healing:**

   Watch the reconciliation loop automatically detect and fix the drift within 5 seconds.

![watch output 3](watch_-n_5_(3).png)
