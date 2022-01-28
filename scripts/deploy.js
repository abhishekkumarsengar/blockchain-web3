
const {ethers } = require("hardhat");

async function main() {
    const Nft = await ethers.getContractFactory("NFT");
    const nft = await Nft.deploy("Friends", "FRN");
    await nft.deployed();
    console.log("Contact deployed to : ", nft.address);
    await nft.mint("https://ipfs.io/ipfs/QmNr9TEKA63K6tJPSgFftRaSvce76ETbVWnvANXEjiQ5Mm");
    console.log("NFT minted");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
