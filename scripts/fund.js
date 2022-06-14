const { assert, expect } = require("chai")
const { deployments, ethers, getNamedAccounts } = require("hardhat")

async function main() {
    const sendValue = ethers.utils.parseEther("1000")
    const { deployer } = await getNamedAccounts()
    await deployments.fixture(["all"])
    const fundMe = await ethers.getContract("FundMe", deployer)
    console.log("Funding contract...")

    const transactionResponse = await fundMe.fund({ value: sendValue })
    await transactionResponse.wait(1)
    console.log("Funded Properly")
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit
    })
