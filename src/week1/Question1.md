# Markdown File 1 - ERC Comparisons

## ERC-777

<b>Q: What problems do ERC777 and ERC1363 solve? Why was ERC1363 introduced, and what issues are there with ERC777??</b>

A: ERC 777 defines a new way to interact w/ a token contracts while remaining (mostly) compatible with the original
ERC-20 token standard.

THe primary feature changes are the addition of operators and hooks.

Operators allow for tokens to be sent on behalf of another address (both eoa and contract).

Hooks take advantage of ERC-1280 to allow both regular contracts and EOAs to be notified of a token sent/received.

These two new features solve some of the original issues associated with ERC-20 tokens.

Issue #1: Inability to automatically react to incoming tokens.

This caused a lot of issues for those interacting with ERC 20 contracts. Tokens were often lost b/c tokens were sent to
contracts that weren't designed to handle them. The `tokensReceived` hook can help prevent this by rejecting such
transactions.

It also allows custom logic, for example emitting events, when tokens are received - which did not exist on the original
ERC 20 token standard.

### Issue #2: Multi-step

Additionally, a limitation of the original ERC-20 token standard was that you had to authorize each time you wanted to
send a token, which requires 2 separate function calls. ERC-777 introduces 2 operators called `authorize` & `revoke`
which allow addresses to specify an address that can perform tasks, like transfer tokens, on their behalf - thus
eliminating the need to call `approve` each time you want to do something on that contract.

### Issue #3: Approvals/allowances/transfers

The original ERC-20 token standard required a multi-step 'approve' (granting permission to another address to spend x
amount of tokens) and a `transferFrom` function to actually move the tokens from the owner to a new account. This has a
few different issues:

1. it's inefficient for sending large amounts of transactions (needs to happen every time)
2. the ability to double spend by malicous contracts

### Problem with ERC 777:

The main problem with ERC 777 is that by introducing this extra custom logic that is called in the receiving contract,
it opens up the possibility for reentrancy since the token contract hands over the execution context to the receiving
contract before completing.

## ERC-1363

Key changes/features:

1. Payments/utility focused (subscriptions, for example - simplifying complex dApp calls)
2. addition of `transferAndCall` and `approveAndCall`

ERC-1363 was introduced to simplify the complexity & reduce gas costs associated with executing business logic (or just
custom logic in general) after receiving a ERC-20 transfer/approval. It does this by doing a callback <b> in the same
transaction </b> after a transfer or approval takes place.
