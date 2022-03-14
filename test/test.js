const {
	assert,
	expect
} = require('chai');
const {
	BN,
	time,
	expectRevert,
	constants,
	balance
} = require('@openzeppelin/test-helpers');
const {
	artifacts,
	ethers
} = require('hardhat');

describe("BlockBanana", function () {

	let Token;
	let contract;
	let owner;
	let addr1;
	let addr2;
	let addr3;
	let addrs;

	before(async function () {

		Token = await ethers.getContractFactory("BlockBanana");
		[owner, addr1, addr2, addr3,...addrs] = await ethers.getSigners();

		contract = await Token.deploy();
		console.log("BlockBanana deployed to:", contract.address);

	});

	describe("BlockBanana Test", function () {

		// it("giveaway Function", async function () {
		// 	await contract.connect(owner).setMAX_TOKEN(10000, 10000);

		// 	for (i = 0; i < 100; i++){
		// 		await contract.connect(owner).giveaway(addr2.address, 100);
		// 	}
			
		// 	expect(await contract.totalSupply()).to.equal(10000);

		// });

		it("mintNFT Function", async function () {

			// await contract.connect(owner).setMAX_TOKEN(20000, 10);

			let quantity = 3;
			let maxQuantity = 3;

			const domain = {
				name: 'Block Banana',
				version: '1.0.0',
				chainId: 31337,
				verifyingContract: '0x668eD30aAcC7C7c206aAF1327d733226416233E2'
			};

			const types = {
				NFT: [{
						name: 'addressForClaim',
						type: 'address'
					},
					{
						name: 'maxQuantity',
						type: 'uint256'
					},
				],
			};

			const value = {
				addressForClaim: addr1.address,
				maxQuantity: 3
			};

			signature = await owner._signTypedData(domain, types, value);
			console.log(signature)
			await contract.connect(addr1).mintNFT(quantity, maxQuantity, signature, {value: "600000000000000000"});

		});

		it("withdrawAll Function", async function () {

			await contract.connect(owner).withdrawAll();

		});

		// it("burn Function", async function () {

		// 	await contract.connect(owner).setBurn(1);
		// 	await contract.connect(addr1).burn(addr1.address, 2);
		// });
	});
});