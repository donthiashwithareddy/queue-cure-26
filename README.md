# Queue Cure '26 

A production-ready, full-stack real-time patient queue management platform designed to eliminate paper token slips and provide instant queue visibility for clinics, receptionists, and patients. 

Built for the **Queue Cure '26 Hackathon** hosted on Wooble / Unstop.

---

## Key Architectural Features :
* **Real-Time Architecture Pipeline:** Driven entirely by cross-platform WebSockets (`socket.io`) for instantaneous data broadcasting across all viewport windows without hard page refreshes.
* **Fast & Mistake-Proof Operations:** Features a built-in **2-second debounce mechanism** on critical queue console buttons to intercept and neutralize accidental double-clicks or spammed user interactions.
* **Dynamic Math Estimation Mapping:** Instantly tracks index sequences and updates system metrics globally using live state array lengths ($Index \times \text{Benchmark Time}$).
* **IndexedStack State Preservation:** Preserves active cross-origin pipelines and connection instances across the main navigation sidebar rails seamlessly without structural teardowns.
* **Visual Fault-Tolerance Wrapper:** Integrates a responsive client-side connection interceptor banner that freezes layouts and self-heals the handshake when the backend connection state shifts.

---

## System Tech Stack
* **Frontend Client:** Flutter Web Engine (Type-Safe Context Dart Architecture)
* **Backend Thread Console:** Node.js Runtime Environment
* **Real-Time Layer:** Socket.io Engine Protocol

---

## Local Installation & Execution

Follow these clean steps to run the complete environment locally on your desktop machine:

### 1. Initialize the Node.js Server Environment
```bash
# Navigate to your backend directory
cd backend

# Install production dependencies
npm install

# Initialize the central engine thread
node server.js
