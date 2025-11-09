;; Crisis Stabilization Coordinator
;; Manages crisis bed placement, psychiatric evaluations, stabilization care, and community transitions

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-not-found (err u102))
(define-constant err-already-exists (err u103))
(define-constant err-invalid-input (err u104))
(define-constant err-no-capacity (err u105))
(define-constant err-invalid-status (err u106))

;; Data Variables
(define-data-var facility-counter uint u0)
(define-data-var admission-counter uint u0)
(define-data-var evaluation-counter uint u0)
(define-data-var care-plan-counter uint u0)
(define-data-var transition-counter uint u0)
(define-data-var outcome-counter uint u0)

;; Data Maps

;; Crisis Bed Facilities
(define-map facilities
    { facility-id: uint }
    {
        name: (string-ascii 100),
        total-beds: uint,
        available-beds: uint,
        facility-type: (string-ascii 50),
        is-active: bool,
        manager: principal
    }
)

;; Patient Admissions
(define-map admissions
    { admission-id: uint }
    {
        patient-id: (string-ascii 100),
        facility-id: uint,
        admission-date: uint,
        discharge-date: (optional uint),
        bed-number: uint,
        status: (string-ascii 20),
        admitting-provider: principal
    }
)

;; Psychiatric Evaluations
(define-map evaluations
    { evaluation-id: uint }
    {
        admission-id: uint,
        evaluator-id: (string-ascii 100),
        evaluation-date: uint,
        risk-level: (string-ascii 20),
        diagnosis-code: (string-ascii 50),
        recommendations: (string-ascii 500),
        completed: bool
    }
)

;; Care Plans
(define-map care-plans
    { plan-id: uint }
    {
        admission-id: uint,
        created-date: uint,
        interventions: (string-ascii 500),
        medications: (string-ascii 300),
        therapy-schedule: (string-ascii 200),
        safety-level: (string-ascii 20),
        updated-by: principal
    }
)

;; Transition Plans
(define-map transitions
    { transition-id: uint }
    {
        admission-id: uint,
        planned-discharge: uint,
        actual-discharge: (optional uint),
        referral-services: (string-ascii 500),
        follow-up-date: uint,
        housing-status: (string-ascii 50),
        completed: bool
    }
)

;; Outcome Records
(define-map outcomes
    { outcome-id: uint }
    {
        admission-id: uint,
        readmitted: bool,
        readmission-date: (optional uint),
        days-stable: uint,
        follow-up-completed: bool,
        quality-score: uint,
        recorded-date: uint
    }
)

;; Authorization map for providers
(define-map authorized-providers
    { provider: principal }
    { authorized: bool }
)

;; Read-only functions

(define-read-only (get-facility (facility-id uint))
    (map-get? facilities { facility-id: facility-id })
)

(define-read-only (get-admission (admission-id uint))
    (map-get? admissions { admission-id: admission-id })
)

(define-read-only (get-evaluation (evaluation-id uint))
    (map-get? evaluations { evaluation-id: evaluation-id })
)

(define-read-only (get-care-plan (plan-id uint))
    (map-get? care-plans { plan-id: plan-id })
)

(define-read-only (get-transition (transition-id uint))
    (map-get? transitions { transition-id: transition-id })
)

(define-read-only (get-outcome (outcome-id uint))
    (map-get? outcomes { outcome-id: outcome-id })
)

(define-read-only (is-authorized (provider principal))
    (default-to false (get authorized (map-get? authorized-providers { provider: provider })))
)

(define-read-only (get-facility-availability (facility-id uint))
    (match (get-facility facility-id)
        facility (ok (get available-beds facility))
        (err err-not-found)
    )
)

;; Public functions

;; Register a new crisis facility
(define-public (register-facility (name (string-ascii 100)) (total-beds uint) (facility-type (string-ascii 50)))
    (let
        (
            (new-facility-id (+ (var-get facility-counter) u1))
        )
        (asserts! (or (is-eq tx-sender contract-owner) (is-authorized tx-sender)) err-not-authorized)
        (asserts! (> total-beds u0) err-invalid-input)
        
        (map-set facilities
            { facility-id: new-facility-id }
            {
                name: name,
                total-beds: total-beds,
                available-beds: total-beds,
                facility-type: facility-type,
                is-active: true,
                manager: tx-sender
            }
        )
        (var-set facility-counter new-facility-id)
        (ok new-facility-id)
    )
)

;; Admit a patient to crisis bed
(define-public (admit-patient 
    (patient-id (string-ascii 100))
    (facility-id uint)
    (bed-number uint)
    (admission-date uint))
    (let
        (
            (facility (unwrap! (get-facility facility-id) err-not-found))
            (new-admission-id (+ (var-get admission-counter) u1))
        )
        (asserts! (is-authorized tx-sender) err-not-authorized)
        (asserts! (get is-active facility) err-invalid-status)
        (asserts! (> (get available-beds facility) u0) err-no-capacity)
        
        (map-set admissions
            { admission-id: new-admission-id }
            {
                patient-id: patient-id,
                facility-id: facility-id,
                admission-date: admission-date,
                discharge-date: none,
                bed-number: bed-number,
                status: "admitted",
                admitting-provider: tx-sender
            }
        )
        
        (map-set facilities
            { facility-id: facility-id }
            (merge facility { available-beds: (- (get available-beds facility) u1) })
        )
        
        (var-set admission-counter new-admission-id)
        (ok new-admission-id)
    )
)

;; Schedule psychiatric evaluation
(define-public (schedule-evaluation
    (admission-id uint)
    (evaluator-id (string-ascii 100))
    (evaluation-date uint)
    (risk-level (string-ascii 20))
    (diagnosis-code (string-ascii 50))
    (recommendations (string-ascii 500)))
    (let
        (
            (admission (unwrap! (get-admission admission-id) err-not-found))
            (new-eval-id (+ (var-get evaluation-counter) u1))
        )
        (asserts! (is-authorized tx-sender) err-not-authorized)
        
        (map-set evaluations
            { evaluation-id: new-eval-id }
            {
                admission-id: admission-id,
                evaluator-id: evaluator-id,
                evaluation-date: evaluation-date,
                risk-level: risk-level,
                diagnosis-code: diagnosis-code,
                recommendations: recommendations,
                completed: true
            }
        )
        
        (var-set evaluation-counter new-eval-id)
        (ok new-eval-id)
    )
)

;; Create care plan
(define-public (create-care-plan
    (admission-id uint)
    (interventions (string-ascii 500))
    (medications (string-ascii 300))
    (therapy-schedule (string-ascii 200))
    (safety-level (string-ascii 20))
    (created-date uint))
    (let
        (
            (admission (unwrap! (get-admission admission-id) err-not-found))
            (new-plan-id (+ (var-get care-plan-counter) u1))
        )
        (asserts! (is-authorized tx-sender) err-not-authorized)
        
        (map-set care-plans
            { plan-id: new-plan-id }
            {
                admission-id: admission-id,
                created-date: created-date,
                interventions: interventions,
                medications: medications,
                therapy-schedule: therapy-schedule,
                safety-level: safety-level,
                updated-by: tx-sender
            }
        )
        
        (var-set care-plan-counter new-plan-id)
        (ok new-plan-id)
    )
)

;; Create transition plan
(define-public (create-transition-plan
    (admission-id uint)
    (planned-discharge uint)
    (referral-services (string-ascii 500))
    (follow-up-date uint)
    (housing-status (string-ascii 50)))
    (let
        (
            (admission (unwrap! (get-admission admission-id) err-not-found))
            (new-transition-id (+ (var-get transition-counter) u1))
        )
        (asserts! (is-authorized tx-sender) err-not-authorized)
        
        (map-set transitions
            { transition-id: new-transition-id }
            {
                admission-id: admission-id,
                planned-discharge: planned-discharge,
                actual-discharge: none,
                referral-services: referral-services,
                follow-up-date: follow-up-date,
                housing-status: housing-status,
                completed: false
            }
        )
        
        (var-set transition-counter new-transition-id)
        (ok new-transition-id)
    )
)

;; Discharge patient
(define-public (discharge-patient (admission-id uint) (discharge-date uint))
    (let
        (
            (admission (unwrap! (get-admission admission-id) err-not-found))
            (facility (unwrap! (get-facility (get facility-id admission)) err-not-found))
        )
        (asserts! (is-authorized tx-sender) err-not-authorized)
        (asserts! (is-eq (get status admission) "admitted") err-invalid-status)
        
        (map-set admissions
            { admission-id: admission-id }
            (merge admission { 
                discharge-date: (some discharge-date),
                status: "discharged"
            })
        )
        
        (map-set facilities
            { facility-id: (get facility-id admission) }
            (merge facility { available-beds: (+ (get available-beds facility) u1) })
        )
        
        (ok true)
    )
)

;; Record outcome
(define-public (record-outcome
    (admission-id uint)
    (readmitted bool)
    (readmission-date (optional uint))
    (days-stable uint)
    (follow-up-completed bool)
    (quality-score uint)
    (recorded-date uint))
    (let
        (
            (admission (unwrap! (get-admission admission-id) err-not-found))
            (new-outcome-id (+ (var-get outcome-counter) u1))
        )
        (asserts! (is-authorized tx-sender) err-not-authorized)
        (asserts! (<= quality-score u100) err-invalid-input)
        
        (map-set outcomes
            { outcome-id: new-outcome-id }
            {
                admission-id: admission-id,
                readmitted: readmitted,
                readmission-date: readmission-date,
                days-stable: days-stable,
                follow-up-completed: follow-up-completed,
                quality-score: quality-score,
                recorded-date: recorded-date
            }
        )
        
        (var-set outcome-counter new-outcome-id)
        (ok new-outcome-id)
    )
)

;; Authorize provider
(define-public (authorize-provider (provider principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set authorized-providers { provider: provider } { authorized: true }))
    )
)

;; Revoke provider authorization
(define-public (revoke-provider (provider principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set authorized-providers { provider: provider } { authorized: false }))
    )
)

;; Update facility status
(define-public (update-facility-status (facility-id uint) (is-active bool))
    (let
        (
            (facility (unwrap! (get-facility facility-id) err-not-found))
        )
        (asserts! (or (is-eq tx-sender contract-owner) (is-eq tx-sender (get manager facility))) err-not-authorized)
        
        (ok (map-set facilities
            { facility-id: facility-id }
            (merge facility { is-active: is-active })
        ))
    )
)
