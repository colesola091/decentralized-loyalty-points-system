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

(define-public (burn-point (point-id uint))
    (let ((point-owner (unwrap! (nft-get-owner? loyalty-point point-id) err-token-not-found)))
        (asserts! (is-eq tx-sender point-owner) err-not-token-owner)
        (asserts! (not (has-point-burned point-id)) err-already-burned)
        (try! (nft-burn? loyalty-point point-id point-owner))
        (map-set burned-points point-id true)
        (ok true)))

(define-public (transfer-point (point-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq recipient tx-sender) err-not-token-owner)
        (asserts! (not (has-point-burned point-id)) err-already-burned)
        (let ((actual-sender (unwrap! (nft-get-owner? loyalty-point point-id) err-not-token-owner)))
            (asserts! (is-eq actual-sender sender) err-not-token-owner)
            (try! (nft-transfer? loyalty-point point-id sender recipient))
            (ok true))))

(define-public (update-point-uri (point-id uint) (new-uri (string-ascii 256)))
    (begin
        (let ((point-owner (unwrap! (nft-get-owner? loyalty-point point-id) err-token-not-found)))
            (asserts! (is-eq point-owner tx-sender) err-not-token-owner)
            (asserts! (is-valid-uri new-uri) err-invalid-uri)
            (map-set point-uri point-id new-uri)
            (ok true))))

;; Read-Only Functions
(define-read-only (get-point-uri (point-id uint))
    (ok (map-get? point-uri point-id)))

(define-read-only (get-point-owner (point-id uint))
    (ok (nft-get-owner? loyalty-point point-id)))

(define-read-only (get-last-point-id)
    (ok (var-get last-point-id)))

(define-read-only (is-point-burned (point-id uint))
    (ok (has-point-burned point-id)))

(define-read-only (get-batch-point-ids (start-id uint) (count uint))
    (ok (map uint-to-response 
        (unwrap-panic (as-max-len? 
            (list-tokens start-id count) 
            u100)))))

(define-private (uint-to-response (id uint))
    {
        point-id: id,
        uri: (unwrap-panic (get-point-uri id)),
        owner: (unwrap-panic (get-point-owner id)),
        burned: (unwrap-panic (is-point-burned id))
    })

(define-private (list-tokens (start uint) (count uint))
    (map + 
        (list start) 
        (generate-sequence count)))

(define-private (generate-sequence (length uint))
    (map - (list length)))

;; Contract initialization
(begin
    (var-set last-point-id u0))
