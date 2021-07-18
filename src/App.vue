<template>
  <div id="app">
    <Navbar :account="account" />
    <Cards v-if="web3" :account="account" :web3="web3" />
  </div>
</template>
<script>
  import Navbar from './components/Navbar.vue';
  import Cards from './components/Cards.vue';
  import Web3 from 'web3';

  export default {
    name: 'navbar',
    components: {
      Navbar,
      Cards,
    },
    data() {
        return {
            account: null,
            web3: null
        }
    },
    mounted() {
        this.connect()
        if (window.ethereum) {
            window.ethereum.on('accountsChanged', function (accounts) {
                location.reload()
            })

            window.ethereum.on('chainChanged', (chainId) => {
                location.reload();
            });
        }
    },
    methods:{
        async connect () {
            if (window.ethereum) {
                window.ethereum
                    .request({
                        method: 'eth_requestAccounts',
                    })
                    .then((result) => {
                        this.account = result[0]
                        this.web3 = new Web3(window.ethereum)
                    })
                    .catch((error) => {
                        console.log(error)
                        // If the request fails, the Promise will reject with an error.
                    });
            } else if (window.web3) {
                this.web3 = new Web3(window.web3.currentProvider)
            }
        }
    }
  }
</script>