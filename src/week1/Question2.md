# Markdown File 2 - SafeERC20

## Why does the program exist?

There are a few reasons why it exists:

1. Unspecified ERC-20 return types

- Since the ERC-20 token standard did not explicitly specify the return type for `transfer`, `transferFrom`, and
  `approve` (should return a boolean, but non-compliant/older ones don't follow this)

2. Mitigating reentrancy attacks

- since re-entrancy is possible with the basse/original erc-20 token standard, `safeERC20` implements a lot of best
  practices to ensure re-entrancy does not occur.

3. Development simplicity/security

- since it's a standardized/tested library, it allows developers to build faster without worrying about the pitfalls of
  the original ERC-20 token standard

## When should it be used?

1. Interacting with multiple ERC-20 tokens (ensures safter/more consistent interactions)
2. Integrating with legacy/non-standard tokens (enhanced security)
3. Any time you're building a contract that relies on token transfers
