# Weir

**Compliance-gated USDC payments on Arc.**

Weir is a small smart contract and web page that screens a recipient before a USDC payment goes out. If the recipient is clean, the payment is delivered. If the recipient is on the blocklist, the payment is refunded to the sender and a `Blocked` event is recorded on-chain, so every screening decision leaves a public trail.

## Why

Sending USDC normally means the money leaves before anyone asks who is receiving it. Businesses paying suppliers, apps paying out rewards, and AI agents paying on their own all need a check at the moment of payment, plus proof that the check happened. Weir puts that check in the payment path itself.

## How it works

1. The sender calls `screenedTransfer(recipient)` on the Weir contract and attaches USDC.
2. The contract looks the recipient up in its blocklist.
3. **Clean:** the USDC is forwarded to the recipient and a `Sent` event is emitted.
4. **Blocked:** the USDC is returned to the sender and a `Blocked` event is emitted. The transaction does not revert, because a revert would erase the event. The refund and the log are what make the decision auditable.

The contract owner manages the blocklist with `setBlocked` and `setBlockedBatch`. Anyone can read a recipient's status with `isBlocked(address)`.

## Why Arc

USDC is Arc's native gas token, so a payment is a plain native transfer. There are no token approvals and no separate gas token to hold. A screened payment costs a fraction of a cent, which makes checking every payment practical.

## Deployments

| Network | Chain ID | Contract |
| --- | --- | --- |
| Arc Testnet | 5042002 | `0x039c77B11A09Ee9B8C458992b5d4a0C8Fb5B2473` |
| Arc Mainnet | 5042 | TBD |

Testnet proof transactions on [explorer.testnet.arc.io](https://explorer.testnet.arc.io):

- Blocklist the burn address: [`0xd63039b7...0cb4`](https://explorer.testnet.arc.io/tx/0xd63039b7f27abbf3e8b75b40b4249596bf9316caf998fa8595a5550e43a20cb4)
- Clean payment delivered: [`0x90faa690...fe18`](https://explorer.testnet.arc.io/tx/0x90faa690fc6d966a992bc0a5fd33ce98104ea38eeb5a8530de6a7e5093d6fe18)
- Blocked payment refunded: [`0xef9cf008...561c`](https://explorer.testnet.arc.io/tx/0xef9cf0083421c3a4cb8810290fc1c987166282a8cc2824b269324f98a44e561c)

Mainnet links will be added here after deployment.

## Try it

Open `index.html` in a browser.

- **Check** tells you whether an address is blocked. It needs no wallet.
- **Send** connects a browser wallet, switches to Arc, and sends through the contract. It reports "Sent" or "Blocked - refunded" with an explorer link.
- The "Fill blocked example" button enters the burn address, which is blocklisted on testnet.

To point the page at mainnet, set `ACTIVE` to `"mainnet"` in the config block at the top of the script and paste the deployed address.

## Develop

Requires [Foundry](https://book.getfoundry.sh/).

```
forge test
```

Deploy:

```
forge create src/ScreenedTransfer.sol:ScreenedTransfer \
  --rpc-url RPC_URL \
  --chain-id CHAIN_ID \
  --private-key $PRIVATE_KEY \
  --broadcast
```

## Limitations

- The blocklist is set by the contract owner. Weir does not read from a sanctions oracle or an external attestation service.
- The contract has not been audited. It is a hackathon-stage build.
- Weir screens the recipient address only, not the sender or the transaction pattern.

## Next

A pluggable screening source, so the blocklist can come from an on-chain attestation or oracle instead of a single owner key.

## License

MIT
