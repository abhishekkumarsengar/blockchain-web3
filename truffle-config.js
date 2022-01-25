module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 7545,            // port for ganache local development
      network_id: "*",       // Any network (default: none)
    }
  },
  // Configure your compilers
  compilers: {
    solc: {        // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
         enabled: false,
         runs: 200
       }
    }
  }
};