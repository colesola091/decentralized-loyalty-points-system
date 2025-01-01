# Decentralized Loyalty Points System

This decentralized loyalty points system is a smart contract built on Clarity for managing and distributing loyalty points as non-fungible tokens (NFTs). It allows the minting, burning, transferring, and updating of loyalty points while ensuring strict owner-only control over the minting process. Additionally, the system supports batch minting, token ownership validation, and URI updates for each loyalty point.

## Features

- **Mint Loyalty Points**: The owner of the contract can mint new loyalty points with a unique URI.
- **Batch Minting**: Multiple loyalty points can be minted in one transaction, subject to batch size limits.
- **Burn Loyalty Points**: Loyalty points can be burned (destroyed) by their owners.
- **Transfer Loyalty Points**: Owners can transfer their loyalty points to other users.
- **Update Point URI**: The owner can update the URI associated with a loyalty point.
- **Ownership and Validation**: Ensures that only the contract owner can mint new loyalty points and that only valid owners can burn or transfer points.

## Contract Components

### Constants
The contract defines several constants such as the contract owner, error messages, and maximum batch size.

### Data Variables
- **Loyalty Point NFT**: Non-fungible tokens representing the loyalty points.
- **Last Point ID**: Tracks the ID of the most recently minted loyalty point.

### Maps
- **Point URI**: Maps loyalty point IDs to their corresponding URIs.
- **Burned Points**: Keeps track of points that have been burned.

### Functions

#### Public Functions:
- **`mint-point(uri-data)`**: Mints a new loyalty point with a given URI.
- **`batch-mint-points(uris)`**: Mints multiple loyalty points in a single transaction.
- **`burn-point(point-id)`**: Burns a specific loyalty point.
- **`transfer-point(point-id, sender, recipient)`**: Transfers a loyalty point from one user to another.
- **`update-point-uri(point-id, new-uri)`**: Updates the URI associated with a specific loyalty point.

#### Read-Only Functions:
- **`get-point-uri(point-id)`**: Fetches the URI of a specific loyalty point.
- **`get-point-owner(point-id)`**: Fetches the owner of a specific loyalty point.
- **`get-last-point-id()`**: Returns the ID of the most recently minted loyalty point.
- **`is-point-burned(point-id)`**: Checks if a specific loyalty point has been burned.
- **`get-batch-point-ids(start-id, count)`**: Fetches a list of loyalty points starting from a given ID, up to a specified count.

### Error Handling
- The contract uses custom error codes to handle various validation errors, including invalid URI, ownership checks, and more.

## Deployment Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/loyalty-points-system.git
   cd loyalty-points-system
   ```

2. Deploy the smart contract to the Clarity blockchain.

3. Interact with the contract using Clarity transaction methods.

## Usage

### Mint a Loyalty Point

Mint a new loyalty point by calling the `mint-point` function with a URI:

```bash
mint-point("http://example.com/loyalty-point-uri")
```

### Batch Mint Loyalty Points

Mint multiple loyalty points at once:

```bash
batch-mint-points(["http://example.com/loyalty1", "http://example.com/loyalty2"])
```

### Burn a Loyalty Point

Burn a specific loyalty point:

```bash
burn-point(1)
```

### Transfer a Loyalty Point

Transfer a loyalty point from one user to another:

```bash
transfer-point(1, "sender-principal", "recipient-principal")
```

### Update the URI of a Loyalty Point

Update the URI of an existing loyalty point:

```bash
update-point-uri(1, "http://newuri.com/loyalty-point")
```

## Contributing

Feel free to fork this repository and submit issues or pull requests for new features, enhancements, or bug fixes. All contributions are welcome!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
