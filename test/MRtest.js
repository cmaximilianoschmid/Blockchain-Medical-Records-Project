const MedRec = artifacts.require("MedRec")
const truffleAssert = require('truffle-assertions');

contract("MedRec", accounts => {
    it("Should throw an error if the person's birth date is not valid", async () => {
        let i = await MedRec.deployed()

        await truffleAssert.reverts(
            i.createEditPerson("0x16e0ce1676011ae279263805dc582139aca2ce3b", 2050, 35, 6, 0)
        )
    })

    it("Should create a person successfully if the input data is valid", async () => {
        let i = await MedRec.deployed()

        await truffleAssert.passes(
            i.createEditPerson("0x16e0ce1676011ae279263805dc582139aca2ce3b", 1990, 04, 6, 0)
        )
    })

    it("Should have two items in 'checkValueHistory' if the basic personal data is updated twice", async () => {
        let i = await MedRec.deployed()
        i.createEditPerson("0x554891521686e807308b5fb0525b3c52a91c74f7", 1983, 06, 03, 1, {from: accounts[9]});
        i.createEditPerson("0x554891521686e807308b5fb0525b3c52a91c74f7", 1983, 06, 04, 1, {from: accounts[9]});

        let CVHLength = await i.getCheckValueHistoryLength(accounts[9])
        assert(CVHLength == 2);
    })

    it("Should not allow unauthorized addresses to getPersonalData", async () => {
        let i = await MedRec.deployed()
        i.createEditPerson("0x0c61c62a0abd474e72b2f3989106d748c23b3c1f", 1983, 06, 04, 1);

        await truffleAssert.reverts(
            i.getPersonalData(accounts[0], {from: accounts[1]})
        )
    })

    it("Should allow authorized addresses to getPersonalData", async () => {
        let i = await MedRec.deployed()
        i.createEditPerson("0x0c61c62a0abd474e72b2f3989106d748c23b3c1f", 1983, 06, 04, 1);

        await truffleAssert.passes(
            i.getPersonalData(accounts[0], {from: accounts[0]})
        )
    })

    it("Should only allow authorized addresses to addMedicalRecord", async () => {
        let i = await MedRec.deployed()
        i.createEditPerson("0xb677579f57858bfe9a1d3a5ba40d3e03e0b15703", 1992, 07, 05, 2, {from: accounts[2]});

        await truffleAssert.reverts( //account 1 should not be allowed to edit account 2
            i.addMedicalRecord(accounts[2], "First Medical Record", "-", "All lab results are fine", "No underlying diseases. Ocupation: developer", "No medication, previously vaccinated", "no injuries", "no surgery", "-" , {from: accounts[1]})
        )

        i.editorAddRemove(true, accounts[1], {from: accounts[2]}) //acount 2 gives edit rights to account 1

        await truffleAssert.passes( //now account 1 should be able to edit account 2
            i.addMedicalRecord(accounts[2], "First Medical Record", "-", "All lab results are fine", "No underlying diseases. Ocupation: developer", "No medication, previously vaccinated", "no injuries", "no surgery", "-" , {from: accounts[1]})
        )

        i.editorAddRemove(false, accounts[1], {from: accounts[2]}) //acount 2 revokes edit rights to account 1

        await truffleAssert.reverts( //now account 1 should not be able to edit account 2
            i.addMedicalRecord(accounts[2], "Second Medical Record", "-", "All lab results are fine", "No underlying diseases. Ocupation: developer", "No medication, previously vaccinated", "no injuries", "no surgery", "-" , {from: accounts[1]})
        )
    })

    it("Should not allow unauthorized addresses to getRecords", async () => {
        let i = await MedRec.deployed()
        i.createEditPerson("0x0c61c62a0abd474e72b2f3989106d748c23b3c1f", 1983, 06, 04, 1);

        await truffleAssert.reverts(
            i.getRecords(accounts[2], {from: accounts[0]})
        )
    })

    it("Should allow authorized addresses to getRecords", async () => {
        let i = await MedRec.deployed()
        i.createEditPerson("0x0c61c62a0abd474e72b2f3989106d748c23b3c1f", 1983, 06, 04, 1);

        await truffleAssert.passes(
            i.getRecords(accounts[2], {from: accounts[2]})
        )
    })

    it("Should only allow to addMedicalRecord to addresses that have a created person", async () => {
        let i = await MedRec.deployed()

        await truffleAssert.reverts( 
            i.addMedicalRecord(accounts[4], "First Medical Record", "-", "All lab results are fine", "No underlying diseases. Ocupation: developer", "No medication, previously vaccinated", "no injuries", "no surgery", "-" , {from: accounts[4]})
        )

        i.createEditPerson("0x46b7d89e895d5906389a8c11725ff50550622ce9", 1976, 10, 23, 0, {from: accounts[4]}); //creating person

        await truffleAssert.passes(
            i.addMedicalRecord(accounts[4], "First Medical Record", "-", "All lab results are fine", "No underlying diseases. Ocupation: developer", "No medication, previously vaccinated", "no injuries", "no surgery", "-" , {from: accounts[4]})
        )
    })
    
})