pragma solidity 0.8.1;

import "./BokkyPooBahsDateTimeContract.sol";

contract MedRec is BokkyPooBahsDateTimeContract{
    
    enum Gender{
        Male, Female, Other
    }
    
    struct Person{
        string hashed_fullName_birthCountry_nationalID;   // variables should be concatenated and hashed on client side before entering blockchain to protect privacy
        uint birthYear;
        uint birthMonth;
        uint birthDay;
        Gender gender;
        bytes32 checkValueCurrent;        //based on the previous varibles
        bytes32[] checkValueHistory;
        MedicalRecord[] recordList;
        address owner;
        address[] viewers;
        mapping (address => bool) viewer;
        address[] editors;
        mapping (address => bool) editor;
    }
    
    struct MedicalRecord{      //https://www.practicefusion.com/medical-charts/
        uint recordDate;
        address recordCreator;
        string description;
        string extReferences;
        string laboratoryResult;
        string underlyingDisease_familyData_habitsAndOccupation;
        string medicationOrVaccines;
        string injury;
        string surgery;
        string other;
    }
    
    mapping (address => Person) private persons;
    
    event personCreatedOrUpdated(address pers);
    event viewerAdded(address party);
    event viewerRemoved(address party);
    event editorAdded(address party);
    event editorRemoved(address party);

    function createEditPerson(string memory _hashed_fullName_birthCountry_nationalID, uint _birthYear, uint _birthMonth, uint _birthDay, Gender _gender) public {
        require(isValidDate(_birthYear, _birthMonth, _birthDay), "Please insert a valid date in YYYY MM DD format");
        require(timestampFromDate(_birthYear, _birthMonth, _birthDay) <= block.timestamp, "Birth date can't be in the future.");
        persons[msg.sender].hashed_fullName_birthCountry_nationalID = _hashed_fullName_birthCountry_nationalID;
        persons[msg.sender].birthYear = _birthYear;
        persons[msg.sender].birthMonth = _birthMonth;
        persons[msg.sender].birthDay = _birthDay;
        persons[msg.sender].gender = _gender;
        persons[msg.sender].owner = msg.sender;
        
        persons[msg.sender].checkValueCurrent = keccak256(abi.encodePacked(_hashed_fullName_birthCountry_nationalID, _birthYear, _birthMonth, _birthDay, _gender));
        persons[msg.sender].checkValueHistory.push(persons[msg.sender].checkValueCurrent);
        
        if(persons[msg.sender].viewer[msg.sender] == false){
            viewerAddRemove(true, msg.sender);
        }
        if(persons[msg.sender].editor[msg.sender] == false){
            editorAddRemove(true, msg.sender);
        }
        
        emit personCreatedOrUpdated(msg.sender);
    }

    function getPersonalData(address _patient) public view returns(string memory, uint, uint, uint, Gender, bytes32, bytes32[] memory){
        require(persons[_patient].viewer[msg.sender] == true, "You don't have permission to view.");
        return (
            persons[_patient].hashed_fullName_birthCountry_nationalID,
            persons[_patient].birthYear,
            persons[_patient].birthMonth,
            persons[_patient].birthDay,
            persons[_patient].gender,
            persons[_patient].checkValueCurrent,
            persons[_patient].checkValueHistory);
    }

    function getCheckValueHistoryLength(address _patient) public view returns(uint){     //just for testing purposes
        uint length = persons[_patient].checkValueHistory.length;
        return length;
    }

    function getRecords(address _patient) public view returns(MedicalRecord[] memory){
        require(persons[_patient].viewer[msg.sender] == true, "You don't have permission to view.");
        return persons[_patient].recordList;
    }
    
    function addMedicalRecord(address _patient, string memory _description, string memory _extReferences, string memory _laboratoryResult, string memory _underlyingDisease_familyData_habitsAndOccupation, string memory _medicationOrVaccines, string memory _injury, string memory _surgery, string memory _other) public {
        require(persons[_patient].editor[msg.sender] == true, "You don't have permission to edit.");
        require(persons[_patient].birthDay != 0, "Personal data should be filled first.");
        MedicalRecord memory recordToAdd;
        recordToAdd.recordDate = block.timestamp;
        recordToAdd.recordCreator = msg.sender;
        recordToAdd.description = _description;
        recordToAdd.extReferences = _extReferences;
        recordToAdd.laboratoryResult = _laboratoryResult;
        recordToAdd.underlyingDisease_familyData_habitsAndOccupation = _underlyingDisease_familyData_habitsAndOccupation;
        recordToAdd.medicationOrVaccines = _medicationOrVaccines;
        recordToAdd.injury = _injury;
        recordToAdd.surgery = _surgery;
        recordToAdd.other = _other;
        persons[_patient].recordList.push(recordToAdd);
    }
    
    function viewerAddRemove(bool addRemove, address party) public {
        if(addRemove == true){
            require (persons[msg.sender].viewer[party] == false, "That party already has view permission.");
            persons[msg.sender].viewers.push(party);
            persons[msg.sender].viewer[party] = true;
            emit viewerAdded(party);
        }
        else{
            uint l = persons[msg.sender].viewers.length;
            require (persons[msg.sender].viewer[party] == true, "That party already has no view permission.");
            for(uint i=0; i<l; i++){
                if(persons[msg.sender].viewers[i] == party){
                    persons[msg.sender].viewers[i] = persons[msg.sender].viewers[l-1];
                    persons[msg.sender].viewers.pop();
                    persons[msg.sender].viewer[party] = false;
                    emit viewerRemoved(party);
                }
            }
        }
    }
    
    function editorAddRemove(bool addRemove, address party) public {
        if(addRemove == true){
            require (persons[msg.sender].editor[party] == false, "That party already has edit permission.");
            persons[msg.sender].editors.push(party);
            persons[msg.sender].editor[party] = true;
            emit editorAdded(party);
        }
        else{
            uint l = persons[msg.sender].editors.length;
            require (persons[msg.sender].editor[party] == true, "That party already has no edit permission.");
            for(uint i=0; i<l; i++){
                if(persons[msg.sender].editors[i] == party){
                    persons[msg.sender].editors[i] = persons[msg.sender].editors[l-1];
                    persons[msg.sender].editors.pop();
                    persons[msg.sender].editor[party] = false;
                    emit editorRemoved(party);
                }
            }
        }
    }
    
    function getYourViewers() public view returns(address[] memory){
        return persons[msg.sender].viewers;
    }
    
    function getYourEditors() public view returns(address[] memory){
        return persons[msg.sender].editors;
    }
    
}