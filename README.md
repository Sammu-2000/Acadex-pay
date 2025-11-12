# EduPay Ledger v2

**EduPay Ledger v2** — *Blockchain-based School Fee Payment and Receipt Tracking*  

Version: 2.0  
Author: Marvellous Okoh  
Platform: Stacks Blockchain (Clarity Language)  

---

## Overview

**EduPay Ledger v2** is a decentralized smart contract for managing **school fee payments** and **receipts** on the **Stacks blockchain**. The contract ensures transparent, secure, and tamper-proof tracking of student enrollments, school fees, and payment history.

This system benefits:
- Schools: Automated collection of fees and transparent record keeping.
- Parents: Safe and verifiable payments.
- Administrators: Efficient student and school management.

---

## Features

### Admin Functions
- Register new schools with wallet, name, and fee.
- Update school fee amounts.
- Transfer admin privileges to another account.

### Student Management
- Enroll students under a specific school.
- Track student details including parent and school association.

### Payment System
- Parents can pay school fees directly to the school's wallet.
- Automatic generation of unique payment receipts with on-chain records.
- Track all payments transparently.

### Read-Only Functions
- Retrieve school information by ID.
- Retrieve student information by ID.
- Retrieve payment information by payment ID.
- Verify payments made by a specific student.

### Security & Validations
- Only the admin can perform school and fee management.
- Only authorized parents can make payments for their children.
- Validations for school and student existence before operations.
- Prevents invalid fee amounts or enrollment entries.

---

## Smart Contract Structure

The contract is implemented in **Clarity** with the following components:

- **Data Variables**
  - `admin`: Principal with admin privileges.
  - `next-school-id`, `next-student-id`, `next-payment-id`: Counters for unique IDs.

- **Maps**
  - `schools`: Stores school information including wallet, name, and fee.
  - `students`: Stores student info including associated school, parent, and name.
  - `payments`: Records all payments including student, payer, amount, and receipt URI.

- **Public Functions**
  - `register-school`, `update-fee`, `transfer-admin`
  - `enroll-student`
  - `pay-fee`

- **Read-Only Functions**
  - `get-school`, `get-student`, `get-payment`, `get-payments-by-student`

---

## Installation & Deployment

1. **Clone the repository**  

```bash
git clone <repository-url>
cd EduPayLedger
