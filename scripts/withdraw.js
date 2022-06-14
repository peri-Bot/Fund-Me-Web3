const { assert, expect } = require("chai")
const { deployments, ethers, getNamedAccounts } = require("hardhat")

async function main() {
    const sendValue = ethers.utils.parseEther("1000")
    const { deployer } = await getNamedAccounts()
    await deployments.fixture(["all"])
    const fundMe = await ethers.getContract("FundMe", deployer)
    console.log("Withdrawing contract...")

    const transactionResponse = await fundMe.withdraw()
    await transactionResponse.wait(1)
    console.log("Withdraw Properly")
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit
    })
