# Swap tokens for Ethereum

## Blockchain

Make .env file in root directory, copy variables from .env.example and set accoridng to your requirement.

Create etherscan account to get dynamic ABI of tokens
See [Etherscan API](https://etherscan.io/apis).

To deploy it on ropsten network you must provide mnemonic of wallet/metamask account in ```.secret``` file of root folder. So just create ```.secret``` file and paste in it.

Run following commands :

```
truffle compile
```

```
truffle migrate --network ropsten
```

## Front end setup
```
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).
