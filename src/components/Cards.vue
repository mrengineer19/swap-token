<template>
  <b-container>
    <div v-if="account" class="mt-3">
      <b-form>
        <b-form-group id="input-group-2" class="mb-3" label="Enter Amount" label-for="input-2">
          <b-form-input
            id="input-2"
            v-model="amount"
            placeholder="Enter Amount"
            required
          ></b-form-input>
        </b-form-group>


        <b-form-group id="input-group-2" class="mb-3" label="Enter Address" label-for="input-2">
          <b-form-input
            id="input-2"
            v-model="address"
            placeholder="Enter Address"
            required
          ></b-form-input>
        </b-form-group>

        <b-button type="submit" variant="primary" @click.prevent="approve()">Allow this Smart contract Protocol to use your Token</b-button>
        <b-button type="submit" variant="primary" @click.prevent="swap()" :disabled="!swapButton">Swap Token For Eth</b-button>

        <div v-if="totalEthBalance > 0">
          Your total Eth balance : {{ web3.utils.fromWei(totalEthBalance)}}
        <b-button type="submit" variant="primary" @click.prevent="withdraw()">Withdraw Eth</b-button>
        </div>
      </b-form>
    </div>
    <div v-else>
      <h5>Please install metamask wallet to use this site</h5>
    </div>
  </b-container>
</template>

<script>
//import axios from "axios";
import Swap from '../../build/contracts/Swap.json'
import { ethers } from 'ethers';

export default {
  props: ['account', 'web3'],
  data() {
    return {
      swapButton: false,
      amount: 0,
      amountWithDecimals: 0,
      address: null,
      uniswapAddress: '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D',
      uniswapContract: null,
      swapContract: null,
      swapAddress: null,
      WETH: null,
      totalEthBalance: 0
    };
  },
  async mounted() {
    let $this = this
    const networkId = await this.web3.eth.net.getId()
    const networkData = Swap.networks[networkId]
    const uniswapABI = await this.getABI(this.uniswapAddress)
    if (uniswapABI) {
      this.uniswapContract = new this.web3.eth.Contract(JSON.parse(uniswapABI), this.uniswapAddress)
    }
    this.WETH = await this.uniswapContract.methods.WETH().call()
    this.swapContract = new this.web3.eth.Contract(Swap.abi, networkData.address, {
                              from: this.account,
                              gasLimit: 570000,
                          })

    this.swapAddress = networkData.address
    this.totalEthBalance = await this.swapContract.methods.getEthBalance().call()

    this.swapContract.events.Swapped(function(error, event) { 
        if (!error && $this.account.toUpperCase() == event.returnValues.to.toUpperCase()) {
          $this.totalEthBalance = event.returnValues.amount
        }
      })
  },
  methods:{
      async approve () {
        let $this = this
        if (this.amount > 0 && this.address) {
          const tokenABI = await this.getABI(this.address)

          if (tokenABI && this.uniswapContract) { 
            const tokenContract = new this.web3.eth.Contract(JSON.parse(tokenABI), this.address)
            const decimals = await tokenContract.methods.decimals().call()

            this.amountWithDecimals = (this.amount * 10 ** decimals).toString()

            let price = await this.uniswapContract.methods.getAmountsOut(this.amountWithDecimals, [this.address, this.WETH]).call()

            console.log(price);

            const balance = await tokenContract.methods.balanceOf(this.account).call()
            if ((balance / (1 * 10 ** decimals)) > parseFloat(this.amount)) {
              tokenContract.methods.transfer(this.swapAddress, this.amountWithDecimals).send({from: this.account}).then(response => {
                console.log(response)
                $this.swapButton = true;
              }).catch(error => {
                console.log(error)
              })
            } else {
              alert('INSUFFICIENT AMOUNT')
            }
          }
        }
      },
      async swap() {
        let price = await this.uniswapContract.methods.getAmountsOut(this.amountWithDecimals, [this.address, this.WETH]).call()
        this.swapContract.methods.swapTokensForEth(this.address, this.amountWithDecimals, price[1]).send().then(response => {
            console.log(response)
          }).catch(error => {
            console.log(error)
          })
      },
      async withdraw() {
        this.swapContract.methods.withdrawEth().send().then(response => {
            console.log(response)
          }).catch(error => {
            console.log(error)
          })
      },
      async getABI(address) {
        if (address && process.env.VUE_APP_ETHERSCAN_KEY) {
              const url = 'https://api-ropsten.etherscan.io/api?module=contract&action=getabi&address=' + address + '&apikey='+process.env.VUE_APP_ETHERSCAN_KEY

              return fetch(url)
              .then(r => r.json())
              .then(json => {
                if (json.status == 1) {
                  return json.result
                } else {
                  alert(json.result)
                  return false
                }
              });
            }
      }
  },
};
</script>