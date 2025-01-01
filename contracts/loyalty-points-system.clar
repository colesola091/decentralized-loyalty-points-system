;; This smart contract implements a decentralized loyalty points system on the blockchain. 
;; It allows the minting, burning, transferring, and management of non-fungible loyalty points. 
;; The contract ensures that only the owner can mint points and provides functionality to manage 
;; point ownership, including transferring points, updating point metadata (URI), and burning points.
;; Key features include batch minting of points, URI validation, and management of burned points.
;; Functions include minting individual or batch points, updating point URIs, and checking point statuses.

;; Decentralized Loyalty Points System
;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u200))
(define-constant err-token-not-found (err u201))
(define-constant err-not-token-owner (err u202))
(define-constant err-token-exists (err u203))
(define-constant err-invalid-uri (err u204))
(define-constant err-already-burned (err u205))
(define-constant err-invalid-batch-size (err u206))
(define-constant max-batch-size u100)

;; Data Variables
(define-non-fungible-token loyalty-point uint)
(define-data-var last-point-id uint u0)

;; Maps
(define-map point-uri uint (string-ascii 256))
(define-map burned-points uint bool)

;; Helper Functions
(define-private (is-valid-owner (point-id uint) (sender principal))
    (is-eq sender (unwrap! (nft-get-owner? loyalty-point point-id) false)))

(define-private (is-valid-uri (uri (string-ascii 256)))
    (let ((uri-length (len uri)))
        (and (>= uri-length u1)
             (<= uri-length u256))))

(define-private (has-point-burned (point-id uint))
    (default-to false (map-get? burned-points point-id)))

(define-private (mint-loyalty-point (uri-data (string-ascii 256)))
    (let ((point-id (+ (var-get last-point-id) u1)))
        (asserts! (is-valid-uri uri-data) err-invalid-uri)
        (try! (nft-mint? loyalty-point point-id tx-sender))
        (map-set point-uri point-id uri-data)
        (var-set last-point-id point-id)
        (ok point-id)))

;; Public Functions
(define-public (mint-point (uri-data (string-ascii 256)))
    (begin
        ;; Ensure the caller is the contract owner
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)

        ;; Validate the URI
        (asserts! (is-valid-uri uri-data) err-invalid-uri)

        ;; Mint the loyalty point
        (mint-loyalty-point uri-data)))

(define-public (batch-mint-points (uris (list 100 (string-ascii 256))))
    (let ((batch-size (len uris)))
        (begin
            (asserts! (is-eq tx-sender contract-owner) err-owner-only)
            (asserts! (<= batch-size max-batch-size) err-invalid-batch-size)
            (asserts! (> batch-size u0) err-invalid-batch-size)

            ;; Mint loyalty points in a batch
            (ok (fold mint-point-in-batch uris (list)))
        )))

(define-private (mint-point-in-batch (uri (string-ascii 256)) (previous-results (list 100 uint)))
    (match (mint-loyalty-point uri)
        success (unwrap-panic (as-max-len? (append previous-results success) u100))
        error previous-results))

