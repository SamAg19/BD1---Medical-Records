var MedicalRecords = artifacts.require("./MedicalRecords.sol");
const bs58 = require('bs58');
const IPFS = require('ipfs-api');
const ipfs = new IPFS({ host: 'ipfs.infura.io', port: 5001, protocol: 'https' });

contract("MedicalRecords", function(accounts) {
    var MedicalRecordsInstance;
    //for testing purposes
    var doc = "text document";
    var bytes;
    //Test case 1
    it("Contract deployment", async() => {
      MedicalRecordsInstance =  await MedicalRecords.deployed()
      assert(MedicalRecordsInstance !== undefined, 'MedicalRecords contract should be defined');
    });

    it("Register Patient", async()=>{
        //Random ID being generated from 1 to 10000000000000
        let id = 1
        let name = "Sameer"
        let age = "20"
        var result = await MedicalRecordsInstance.registerPatient(id,name,age,{from:accounts[0]});
        assert.equal("0x1",result.receipt.status,"Patient not Registered");
    });

    it("Register Doctor", async()=>{
        //Random ID being generated from 1 to 10000000000000
        let id = 1
        let name = "Dr. Anurag"
        let age = "52"
        var result = await MedicalRecordsInstance.registerDoctor(id,name,age,{from:accounts[1]});
        assert.equal("0x1",result.receipt.status,"Doctor not Registered");
        id = 2
        name = "Dr. Santosh"
        age = "45"
        result = await MedicalRecordsInstance.registerDoctor(id,name,age,{from:accounts[2]});
        assert.equal("0x1",result.receipt.status,"Doctor not Registered");
    });

    it("Sameer saving his Report", async()=>{
        let doctor = accounts[1];
        const data = JSON.stringify({
            document: doc
        })
        const doc_bs58 = await ipfs.add(Buffer.from(data))
        const doc_bytes = bs58.decode(doc_bs58[0].hash);
        bytes = '0x' + doc_bytes.slice(2).toString('hex');
        var result = await MedicalRecordsInstance.saveReport(doctor,bytes,{from:accounts[0]})
        assert.equal("0x1",result.receipt.status,"Report not saved");
        let reports = await MedicalRecordsInstance.getPatientReports({from:accounts[0]})
        assert.equal(bytes,reports[0],"Report not verified from patients side")
        let d = await MedicalRecordsInstance.getPatientReportsToDoctors(reports[0],{from:accounts[0]})
        assert.equal(doctor,d[0],"Doctor not authorized to access report")
        let patient = await MedicalRecordsInstance.getDoctorPatients({from:accounts[1]})
        assert.equal(patient[0],accounts[0],"Patient not present in doctor records")
    })
    
    it("File retrieved by Dr. Anurag of patient Sameer", async()=>{
        let report = await MedicalRecordsInstance.getFilesOfPatient(accounts[0],{from:accounts[1]});
        const hex = "1220" + report[0].slice(2)
        const hashBytes = Buffer.from(hex, 'hex');
        const doc_bs58 = bs58.encode(hashBytes)
        const doc_json = await ipfs.cat(doc_bs58)
        let data = JSON.parse(doc_json.toString())['document']
        assert.equal(data,doc,"Data retrieval Unsuccessful")
    })

    it("Dr Santosh trying to retrieve Sameer's report",async()=>{
        let patient = await MedicalRecordsInstance.getDoctorPatients({from:accounts[2]})
        assert.notEqual(patient.length,0,"No patient in Dr. Santosh's database, hence cannot have access to Sameer's file")
    })

    it("Sameer gives permisiion to Dr. Santosh to retrieve his file",async()=>{
        var result = await MedicalRecordsInstance.givePermission(accounts[2],bytes,{from:accounts[0]})
        assert.equal("0x1",result.receipt.status,"Permission not givem");
        let report = await MedicalRecordsInstance.getFilesOfPatient(accounts[0],{from:accounts[2]});
        const hex = "1220" + report[0].slice(2)
        const hashBytes = Buffer.from(hex, 'hex');
        const doc_bs58 = bs58.encode(hashBytes)
        const doc_json = await ipfs.cat(doc_bs58)
        let data = JSON.parse(doc_json.toString())['document']
        assert.equal(data,doc,"Data retrieval Unsuccessful")
    })
});