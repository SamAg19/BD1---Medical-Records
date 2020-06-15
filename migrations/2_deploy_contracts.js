var MedicalRecords = artifacts.require("./MedicalRecords.sol");

module.exports = function(deployer) {
  deployer.deploy(MedicalRecords);
};