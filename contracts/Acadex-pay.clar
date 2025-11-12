;; ============================================================
;; EduPay Ledger v2 - Blockchain School Fee Payment Contract
;; Author: Marvellous Okoh
;; Platform: Stacks Blockchain (Clarity Language)
;; Description: Decentralized school fee payment & receipt tracker
;; ============================================================

;; -------------------------------
;; GLOBAL VARIABLES
;; -------------------------------
(define-data-var admin principal tx-sender)
(define-data-var next-school-id uint u1)
(define-data-var next-student-id uint u1)
(define-data-var next-payment-id uint u1)

;; -------------------------------
;; DATA MAPS
;; -------------------------------
(define-map schools 
  {id: uint} 
  {wallet: principal, name: (string-ascii 50), fee: uint})

(define-map students 
  {id: uint} 
  {school-id: uint, parent: principal, name: (string-ascii 50)})

(define-map payments 
  {pid: uint} 
  {student-id: uint, school-id: uint, payer: principal, amount: uint, receipt-uri: (string-ascii 100)})

;; -------------------------------
;; HELPER FUNCTIONS
;; -------------------------------
(define-read-only (is-admin (user principal))
  (is-eq user (var-get admin))
)

(define-private (assert-admin)
  (if (is-admin tx-sender)
    (ok true)
    (err "ERR_NOT_ADMIN")
  )
)

(define-private (school-exists (school-id uint))
  (is-some (map-get? schools {id: school-id}))
)

(define-private (student-exists (student-id uint))
  (is-some (map-get? students {id: student-id}))
)

;; -------------------------------
;; ADMIN FUNCTIONS
;; -------------------------------

;; Register new school (only admin)
(define-public (register-school (name (string-ascii 50)) (wallet principal) (fee uint))
  (begin
    (try! (assert-admin))
    (asserts! (> fee u0) (err "ERR_INVALID_FEE"))
    (asserts! (not (is-eq wallet tx-sender)) (err "ERR_INVALID_WALLET"))
    (asserts! (not (is-eq name "")) (err "ERR_INVALID_NAME"))
    (let ((sid (var-get next-school-id)))
      (asserts! (> sid u0) (err "ERR_INVALID_ID"))
      (map-set schools {id: sid} {wallet: wallet, name: name, fee: fee})
      (var-set next-school-id (+ sid u1))
      (ok (concat "SCHOOL_REGISTERED_" (int-to-ascii sid)))
    )
  )
)

;; Change admin
(define-public (transfer-admin (new-admin principal))
  (begin
    (try! (assert-admin))
    (asserts! (not (is-eq new-admin tx-sender)) (err "ERR_INVALID_ADMIN"))
    (var-set admin new-admin)
    (ok "ADMIN_CHANGED")
  )
)

;; Enroll a new student (by school)
(define-public (enroll-student (school-id uint) (student-name (string-ascii 50)) (parent principal))
  (begin
    (asserts! (> school-id u0) (err "ERR_INVALID_SCHOOL_ID"))
    (asserts! (not (is-eq parent tx-sender)) (err "ERR_INVALID_PARENT"))
    (asserts! (not (is-eq student-name "")) (err "ERR_INVALID_NAME"))
    (match (map-get? schools {id: school-id})
      school 
      (let ((stid (var-get next-student-id)))
        (asserts! (> stid u0) (err "ERR_INVALID_ID"))
        (map-set students {id: stid} 
          {school-id: school-id, 
           parent: parent, 
           name: student-name})
        (var-set next-student-id (+ stid u1))
        (ok (concat "STUDENT_ENROLLED_" (int-to-ascii stid)))
      )
      (err "ERR_SCHOOL_NOT_FOUND")
    )
  )
)

;; Update school fee (by admin)
(define-public (update-fee (school-id uint) (new-fee uint))
  (begin
    (try! (assert-admin))
    (asserts! (> new-fee u0) (err "ERR_INVALID_FEE"))
    (asserts! (> school-id u0) (err "ERR_INVALID_SCHOOL_ID"))
    (match (map-get? schools {id: school-id})
      school (begin
        (map-set schools {id: school-id} 
          {wallet: (get wallet school), name: (get name school), fee: new-fee})
        (ok "FEE_UPDATED"))
      (err "ERR_SCHOOL_NOT_FOUND")
    )
  )
)



;; -------------------------------
;; SCHOOL FUNCTIONS
;; -------------------------------





;; -------------------------------
;; PAYMENT FUNCTIONS
;; -------------------------------

;; Pay school fees (by parent)
(define-public (pay-fee (student-id uint))
  (begin
    (asserts! (> student-id u0) (err "ERR_INVALID_STUDENT_ID"))
    (let (
          (student (unwrap! (map-get? students {id: student-id}) (err "ERR_STUDENT_NOT_FOUND")))
          (school (unwrap! (map-get? schools {id: (get school-id student)}) (err "ERR_SCHOOL_NOT_FOUND")))
          (fee (get fee school))
          (school-wallet (get wallet school))
         )
      (asserts! (is-eq (get parent student) tx-sender) (err "ERR_NOT_PARENT"))
      (match (stx-transfer? fee tx-sender school-wallet)
        success (let ((pid (var-get next-payment-id))
                     (receipt (concat "https://edu-ledger/receipt/" (int-to-ascii pid))))
                  (map-set payments {pid: pid}
                    {student-id: student-id, 
                     school-id: (get school-id student), 
                     payer: tx-sender, 
                     amount: fee, 
                     receipt-uri: receipt})
                  (var-set next-payment-id (+ pid u1))
                  (ok (concat "PAYMENT_SUCCESS_PID_" (int-to-ascii pid))))
        error (err "STX_TRANSFER_FAILED")
      )
    )
  )
)

;; -------------------------------
;; READ-ONLY FUNCTIONS
;; -------------------------------

;; View school info
(define-read-only (get-school (school-id uint))
  (map-get? schools {id: school-id})
)

;; View student info
(define-read-only (get-student (student-id uint))
  (map-get? students {id: student-id})
)

;; View payment details
(define-read-only (get-payment (pid uint))
  (map-get? payments {pid: pid})
)

;; Verify payment by student
(define-read-only (get-payments-by-student (student-id uint))
  (map-get? payments {pid: student-id})
)

;; -------------------------------
;; END OF CONTRACT
;; -------------------------------
