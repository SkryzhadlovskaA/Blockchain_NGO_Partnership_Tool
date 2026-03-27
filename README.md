# Blockchain_NGO_Partnership_Tool

Overview

NGO Partnership Tool is a blockchain-based prototype designed to support international project partnerships. It allows tracking how many consortiums each NGO participates in and whether they still have available slots to join other projects.
This project demonstrates how smart contracts can be used to create transparent, tamper-proof coordination systems for multi-organization collaboration.

Problem

In international programs (e.g., Erasmus+, Horizon Europe), NGOs often have limits on how many projects they can join. Currently there is no shared system to track participation, and it is difficult to know which partners are still available. It requires looking for their contacts, and sending multiple emails just to find out that the organisation already has all their slots full, then the process repeats...

Solution

This project provides a simple blockchain registry where:
-NGOs are registered with participation limits
-Consortiums(projects) can be created
-NGOs can be added as partners
-Slot usage is tracked automatically, so that you can immediately have an overview of which organisation is available for partnership

Tech Stack
Solidity – Smart contract logic
Ethers.js v6 – Blockchain interaction
HTML / CSS / JavaScript – Frontend UI
Sepolia Testnet – Deployment network
Rabby – Wallet connection

Smart Contract

The contract follows a single-owner model(simplified for project purposes):
-One funded account (owner) performs all transactions
-NGOs are represented by wallet addresses, which can be generated automatically
-Slot limits are enforced on-chain

Key Functions:
registerNGO(...) – Register a new NGO
createConsortium(...) – Create a project
addPartner(...) – Add NGO to consortium
getOpenNGOs() – Get available partners

How to Run
1. Deploy Smart Contract
Open Remix IDE --> Compile the contract --> Deploy using Injected Provider (Rabby) --> Copy the deployed contract address
2. Run Frontend
Open frontend/NGO_Management_UI.html in your browser (using localhost for example) --> Connect your wallet (Step 1 in UI) --> Paste the contract address --> Click Load Contract (Step 2)
3. Use the App
Register NGOs, Create projects, Add partners, View available NGOs

Author
Anastasiia Skryzhadlovska
M. Sc. Student, software developer

Notes
This project is a prototype for academic purposes, demonstrating how blockchain can support coordination and transparency in international collaborations.
