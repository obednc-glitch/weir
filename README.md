# Weir

**Compliance-gated USDC payments on Arc.**

Live demo: https://weir.onrender.com

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

USDC is Arc's native gas token, so a payment is a plain native transfer. There are no token approvals and no separate gas token to hold. A screened payment cost about 0.0007 USDC in gas in our mainnet test, which makes checking every payment practical.

## Deployments

| Network | Chain ID | Contract |
| --- | --- | --- |
| Arc Testnet | 5042002 | `0x039c77B11A09Ee9B8C458992b5d4a0C8Fb5B2473` |
| Arc Mainnet | 5042 | `0x039c77B11A09Ee9B8C458992b5d4a0C8Fb5B2473` |

Testnet proof transactions on [explorer.testnet.arc.io](https://explorer.testnet.arc.io):

- Blocklist the burn address: [`0xd63039b7...0cb4`](https://explorer.testnet.arc.io/tx/0xd63039b7f27abbf3e8b75b40b4249596bf9316caf998fa8595a5550e43a20cb4)
- Clean payment delivered: [`0x90faa690...fe18`](https://explorer.testnet.arc.io/tx/0x90faa690fc6d966a992bc0a5fd33ce98104ea38eeb5a8530de6a7e5093d6fe18)
- Blocked payment refunded: [`0xef9cf008...561c`](https://explorer.testnet.arc.io/tx/0xef9cf0083421c3a4cb8810290fc1c987166282a8cc2824b269324f98a44e561c)

The contract has the same address on both networks because it was deployed from the same wallet at the same nonce.

Mainnet: source verified on [explorer.arc.io](https://explorer.arc.io/address/0x039c77B11A09Ee9B8C458992b5d4a0C8Fb5B2473). Mainnet proof transactions:

- Blocklist the burn address (`setBlocked`): [`0x24487d84...96da`](https://explorer.arc.io/tx/0x24487d841f29f17b6233dd21a58f799bc60fec2522498d8e7d275b9037cd96da)
- Clean payment delivered: [`0x3fab8968...f8be`](https://explorer.arc.io/tx/0x3fab8968d8e053b8f15c6fbb7839b88621b219cca72261f6a182d6fe96fdf8be)
- Blocked payment refunded, from the command line: [`0x000c43e4...79e4`](https://explorer.arc.io/tx/0x000c43e43aeeb217c5683899ea54a24e7c0cfee3645b469977bac334f48a79e4)
- Blocked payment refunded, from the live web page: [`0xd7eb6740...c6b4`](https://explorer.arc.io/tx/0xd7eb6740f183f97040b1c3538f99798b09f859a73db9d10d0fbd5421286dc6b4)

A blocked payment shows as a successful transaction on the explorer, because the contract refunds instead of reverting. Open the transaction's Logs tab to see the `Blocked` event.

## Try it

Open the live page at https://weir.onrender.com. To run it locally, open `index.html` in a browser.

- **Check** tells you whether an address is blocked. It needs no wallet.
- **Send** connects a browser wallet, switches to Arc, and sends through the contract. It reports "Sent" or "Blocked - refunded" with an explorer link.
- The "Fill blocked example" button enters the burn address, which is blocklisted on both testnet and mainnet.

The page is configured for Arc mainnet. To point it at testnet, set `ACTIVE` to `"testnet"` in the config block at the top of the script.

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

- Weir currently screens against one blocklist, set by the contract owner. It does not read from a sanctions oracle or an external attestation service.
- The contract has not been audited. It is a hackathon-stage build.
- Weir currently screens the recipient address only, not the sender or the transaction pattern.
- Weir currently supports native USDC only.

## Roadmap

Weir v1 screens against a single blocklist managed by the contract owner. Planned next:

- **Selectable block lists.** The sender chooses which lists to screen against, one or several, because different payers answer to different rules. A payment is blocked if the recipient is on any selected list.
- **Public lists.** Curated lists anyone can select, starting with a sanctions list and other public lists, so payers don't have to build and maintain their own.
- **Personal lists.** Any user can create and manage their own list for their own reasons, so no single owner key controls everyone's screening.
- **Pluggable sources.** Lists that read from an on-chain attestation or oracle instead of a manually updated list, so screening data stays current without hand edits.
- **Other assets.** The same screening for other tokens, not only native USDC, so the same check can gate more kinds of payments on Arc.

These are plans. They are not features of the deployed contract.

## License

MIT
