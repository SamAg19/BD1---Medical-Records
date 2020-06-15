pragma solidity >=0.4.22 <0.6.0;

contract MedicalRecords {
    
    struct Patient {
        uint ID;
        string Name;
        uint Age;
        bytes32[] reports;
        mapping(bytes32=>address[]) reports_to_doctors;
    }
    
    struct Doctor {
        uint ID;
        string Name;
        uint Age;
        address[] patients;
        mapping(address=>bool) alreadyPatient;
        mapping(address=>bytes32[]) patient_files;
    }
    
    mapping(address=>Patient) patient;
    mapping(uint=>bool) isIDTaken;
    mapping(address=>Doctor) doctor;
    
    function registerPatient(uint _ID,string memory _Name, uint _Age) public{
        require(patient[msg.sender].ID==0,"You have already registered as a patient");

        require(isIDTaken[_ID]==false,"ID Already Taken");
        
        require(_ID!=0,"Invalid ID");
        
        require(keccak256(abi.encodePacked(_Name))!=keccak256(abi.encodePacked("")),"Invalid name");
        
        require(_Age!=0,"Invalid Age");
        
        patient[msg.sender].ID = _ID;
        
        patient[msg.sender].Name = _Name;
        
        patient[msg.sender].Age = _Age;
        
    }    
    
    function registerDoctor(uint _ID,string memory _Name, uint _Age) public{
        require(doctor[msg.sender].ID==0,"You have already registered as a doctor");

        require(isIDTaken[_ID]==false,"ID Already Taken");
        
        require(_ID!=0,"Invalid ID");
        
        require(keccak256(abi.encodePacked(_Name))!=keccak256(abi.encodePacked("")),"Invalid name");
        
        require(_Age!=0,"Invalid Age");
        
        doctor[msg.sender].ID = _ID;
        
        doctor[msg.sender].Name = _Name;
        
        doctor[msg.sender].Age = _Age;
    } 
    
    function saveReport(address _doctor, bytes32 _report) public {
        require(patient[msg.sender].ID!=0,"You have not registered as a patient");
        
        require(doctor[_doctor].ID!=0,"This address has not been registered as a doctor");
        
        patient[msg.sender].reports.push(_report);
        
        patient[msg.sender].reports_to_doctors[_report].push(_doctor);
        
        if(doctor[_doctor].alreadyPatient[msg.sender]==false){
            
            doctor[_doctor].alreadyPatient[msg.sender] = true;
            
            doctor[_doctor].patients.push(msg.sender);
        }
        
        
        doctor[_doctor].patient_files[msg.sender].push(_report);
    }
    
    function givePermission(address _doctor, bytes32 _report)  public {
        require(patient[msg.sender].ID!=0,"You are not a patient");
        
        require(doctor[_doctor].ID!=0,"This address has not been registered as a doctor");
        
        patient[msg.sender].reports_to_doctors[_report].push(_doctor);
        
        if(doctor[_doctor].alreadyPatient[msg.sender]==false){
            
            doctor[_doctor].alreadyPatient[msg.sender] = true;
            
            doctor[_doctor].patients.push(msg.sender);
        }
        
        doctor[_doctor].patient_files[msg.sender].push(_report);
    }
    
        
    function getPatientDetails(address _patient) public view returns(uint256,string memory,uint256){
        
        require(patient[_patient].ID!=0,"You are not a patient");
        
        return (patient[_patient].ID,patient[_patient].Name,patient[_patient].Age);
    }

    function getPatientReports() public view returns(bytes32[] memory) {

        require(patient[msg.sender].ID!=0,"You are not a patient");

        return patient[msg.sender].reports;
    }
    
    function getPatientReportsToDoctors(bytes32 _report) public view returns(address[] memory){
        
        require(patient[msg.sender].ID!=0,"You are not a patient");
        
        return patient[msg.sender].reports_to_doctors[_report];
        
    }

    function getDoctorDetails(address _doctor) public view returns(uint256,string memory,uint256){
        
        require(doctor[_doctor].ID!=0,"This address is not a doctor");
        
        return (doctor[_doctor].ID,doctor[_doctor].Name,doctor[_doctor].Age);
    }

    function getDoctorPatients() public view returns(address[] memory){
        
        require(doctor[msg.sender].ID!=0,"You are not a doctor");
        
        return doctor[msg.sender].patients;
        
    }
    
    function getFilesOfPatient(address _patient) public view returns(bytes32[] memory) {
        require(doctor[msg.sender].ID!=0,"You have not registered as a doctor");
        
        require(patient[_patient].ID!=0,"This address has not been registered as a patient");
        
        require(doctor[msg.sender].alreadyPatient[_patient]==true,"You are not authorized to have access to the files of this patient");
        
        return doctor[msg.sender].patient_files[_patient];
        
    }
    
} 