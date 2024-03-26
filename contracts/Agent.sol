// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "hardhat/console.sol";


contract Agent {
    event ContractDeployed(address indexed _contractAddress);

    constructor() {
        emit ContractDeployed(address(this));
    }

    struct student {
        string fname;
        string lname;
        string university;
        uint enroll;
        uint gender;
        string branch;
        string phone;
        string emailId;
    }

    struct university {
        string name;
        string uaddress;
        string emailId;
        string record;
        string[][] studentNotifications; // Array to store student notifications
        string[][] otherPartyNotifications; // Array to store other party notifications
    }

    struct otherP {
        string name;
        string emailId;
        string record;
        string oaddress;
        uint[] enrollments;
    }

    uint creditPool;

    string[] public studentNames;
    string[] public universityNames;
    string[] public otherPNames;

    mapping(string => address) public studentList;
    mapping(string => address) public universityList;
    mapping(string => address) public otherPList;

    mapping(address => student) studentInfo;
    mapping(address => university) universityInfo;
    mapping(address => otherP) otherPInfo;
    mapping(address => address) Empty;
    mapping(address => mapping(uint => string)) universityEnrollToHash;
    mapping(address => mapping(uint => string)) otherPEnrollToHash;

    // might not be necessary
    // mapping(address => string) patientRecords;

    function add_student(
        string memory _fname,
        string memory _lname,
        string memory _university,
        uint _enroll,
        uint _gender,
        string memory _branch,
        string memory _phone,
        string memory _emailId
    ) public returns (string memory) {
        address addr = msg.sender;
        student memory s;
        s.fname = _fname;
        s.lname = _lname;
        s.university = _university;
        s.enroll = _enroll;
        s.gender = _gender;
        s.branch = _branch;
        s.phone = _phone;
        s.emailId = _emailId;

        studentInfo[msg.sender] = s;
        studentList[_fname] = addr;
        studentNames.push(_fname);
        return _fname;
    }

    function add_university(
        string memory _name,
        string memory _uaddress,
        string memory _emailId
    ) public returns (string memory) {
        address addr = msg.sender;
        university memory u;
        u.name = _name;
        u.uaddress = _uaddress;
        u.emailId = _emailId;

        universityInfo[msg.sender] = u;
        universityList[_name] = addr;
        universityNames.push(_name);
        return u.name;
    }

    function add_otherP(
        string memory _name,
        string memory _oaddress,
        string memory _emailId
    ) public returns (string memory) {
        address addr = msg.sender;
        otherP memory o;
        o.name = _name;
        o.oaddress = _oaddress;
        o.emailId = _emailId;
        // o.record = _hash;
        otherPInfo[msg.sender] = o;
        otherPList[_name] = addr;
        otherPNames.push(_name);
        return o.name;
    }

    event Received(address sender, uint256 value);

    // Fallback function
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function get_student(address addr) public view returns (student memory) {
        return studentInfo[addr];
    }

    function get_university(
        address addr
    ) public view returns (string memory, string memory, string memory) {
        return (
            universityInfo[addr].name,
            universityInfo[addr].uaddress,
            universityInfo[addr].emailId
        );
    }

    function get_otherP(
        address addr
    ) public view returns (string memory, string memory, string memory) {
        return (
            otherPInfo[addr].name,
            otherPInfo[addr].emailId,
            otherPInfo[addr].oaddress
        );
    }

    function getAddressType(address _addr) public view returns (uint) {
        if (bytes(studentInfo[_addr].fname).length > 0) {
            return 1;
        } else if (bytes(universityInfo[_addr].name).length > 0) {
            return 2;
        } else if (bytes(otherPInfo[_addr].name).length > 0) {
            return 3;
        } else {
            return 4;
        }
    }

    function get_student_list() public view returns (string[] memory) {
        return studentNames;
    }

    function get_university_list() public view returns (string[] memory) {
        return universityNames;
    }

    function get_otherP_list() public view returns (string[] memory) {
        return otherPNames;
    }

    //for approving and storing in the university records
    function approveRecord(uint _enroll, string memory _hash) public {
        address addr = msg.sender;
        // Store the hash using the retrieved university address and enrollment number
        universityEnrollToHash[addr][_enroll] = _hash;
        deleteStudentNotification(addr, _enroll);
    }

    function rejectSRecord(uint _enroll) public {
        address addr = msg.sender;
        deleteStudentNotification(addr, _enroll);
    }

    event StudentNotificationAdded(
        string universityName,
        address universityAddress,
        string[][] notifications
    );

    function sendRecordsToUniversity(
        string memory ipfsHash
    ) public returns (string memory, address) {
        // Check if the university exists
        address addr = msg.sender;
        string memory universityName = studentInfo[addr].university;
        address universityAddress = universityList[universityName];
        uint enroll = studentInfo[addr].enroll;

        // Add the IPFS hash to the university's notifications array
        string[] memory notification = new string[](2);
        notification[0] = uint2str(enroll); // Convert uint to string
        notification[1] = ipfsHash;

        universityInfo[universityAddress].studentNotifications.push(
            notification
        );
        // Emit an event with the fetched notifications
        emit StudentNotificationAdded(
            universityName,
            universityAddress,
            universityInfo[universityAddress].studentNotifications
        );

        // Return universityName and universityAddress
        return (universityName, universityAddress);
    }

    function getStudentNotifications() public view returns (string[][] memory) {
        address addr = msg.sender;

        return universityInfo[addr].studentNotifications;
    }

    function deleteStudentNotification(address addr, uint _enroll) public {
        address universityAddress = addr;

        string[][] storage notifications = universityInfo[universityAddress]
            .studentNotifications;

        for (uint i = 0; i < notifications.length; i++) {
            // Convert storage string to memory string before comparison
            if (
                keccak256(abi.encodePacked(notifications[i][0])) ==
                keccak256(abi.encodePacked(uint2str(_enroll)))
            ) {
                // Delete the array at the specified index
                delete universityInfo[universityAddress].studentNotifications[
                    i
                ];
                return;
            }
        }

        // If the enrollment number is not found, revert
        revert("Enrollment not found in notifications");
    }

    function sendOPartyrecordsToUniversity(
        string memory universityName,
        uint enroll
    ) public {
        address addr = msg.sender;
        address universityAddress = universityList[universityName];
        string memory OpName = otherPInfo[addr].name;
        string[] memory notification = new string[](2);
        notification[0] = OpName;
        notification[1] = uint2str(enroll); // Convert uint to string

        universityInfo[universityAddress].otherPartyNotifications.push(
            notification
        );
    }

    function getOtherPNotifications() public view returns (string[][] memory) {
        address addr = msg.sender;

        return universityInfo[addr].otherPartyNotifications;
    }

    function deleteOtherPNotification(
        address addr,
        string memory _name
    ) public {
        address universityAddress = addr;

        string[][] storage notifications = universityInfo[universityAddress]
            .otherPartyNotifications;

        for (uint i = 0; i < notifications.length; i++) {
            // Convert storage string to memory string before comparison
            if (
                keccak256(abi.encodePacked(notifications[i][0])) ==
                keccak256(abi.encodePacked(_name))
            ) {
                // Delete the array at the specified index
                delete universityInfo[universityAddress]
                    .otherPartyNotifications[i];
                return;
            }
        }

        // If the enrollment number is not found, revert
        revert("Name not found in notifications");
    }
event acceptedRequest(
        
        address universityAddress,
        string  name,
        uint[] enrollments
    );
    function acceptRequest(string memory _name, string memory _enroll) public {
        address addr = msg.sender;
        // Store the hash using the retrieved university address and enrollment number
        uint256 enrollment = parseInt(_enroll);
        address opAddr = otherPList[_name];
        string memory _ipfshash = universityEnrollToHash[addr][enrollment];
        otherPEnrollToHash[opAddr][enrollment] = _ipfshash;
        otherPInfo[opAddr].enrollments.push(enrollment);
        emit acceptedRequest(
            addr,
            _enroll,
            otherPInfo[opAddr].enrollments
        );
        deleteOtherPNotification(addr, _name);
    }

    function rejectOrequest(string memory _name) public {
        address addr = msg.sender;
        deleteOtherPNotification(addr, _name);
    }

    function getRecordsofOtherP() public view returns (string[][] memory) {
        address addr = msg.sender;
        uint[] memory _enrollments = otherPInfo[addr].enrollments;
        uint len = _enrollments.length;
        string[][] memory records = new string[][](len);

        // Get the enrollment numbers

        for (uint i = 0; i < len; i++) {
            uint enrollment = _enrollments[i];
            string memory ipfsHash = otherPEnrollToHash[addr][enrollment];
string[] memory record = new string[](2);
            record[0] = uint2str(enrollment);
            record[1] = ipfsHash;
            records[i] = record;
        }

        return records;
    }

    function getRecordsofAllEnroll() public view returns (string[][] memory) {
        // Get the address of the university
        address universityAddress = msg.sender;

        // Initialize the records array with the length of studentNames
        string[][] memory records = new string[][](studentNames.length);

        // Iterate over each student
        for (uint i = 0; i < studentNames.length; i++) {
            string memory studentName = studentNames[i];
            address studentAddress = studentList[studentName];

            // Retrieve student information
            student memory s = studentInfo[studentAddress];

            // Get enrollment number and corresponding IPFS hash
            uint enrollment = s.enroll;
            string memory ipfsHash = universityEnrollToHash[universityAddress][
                enrollment
            ];

            // Create a new array with enrollment number and IPFS hash
            string[] memory record = new string[](2);
            record[0] = uint2str(enrollment);
            record[1] = ipfsHash;

            // Assign the record array to the i-th row of the records 2D array
            records[i] = record;
        }

        return records;
    }

    function getHashByEnrollAndUniversity(
        string memory universityName,
        uint _enroll
    ) public view returns (string memory) {
        // Retrieve the address of the university using the universityName
        address universityAddress = universityList[universityName];
        // Ensure that the university exists
        require(universityAddress != address(0), "University not found");
        // Retrieve the hash associated with the given enrollment number and university address
        string memory hash = universityEnrollToHash[universityAddress][_enroll];

        return hash;
    }

    // Function to convert uint to string (helper function)
    function uint2str(
        uint _i
    ) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1[0];
            _i /= 10;
        }
        return string(bstr);
    }
    // Custom implementation of parseInt
   function parseInt(string memory _value) internal pure returns (uint256) {
        bytes memory _bytesValue = bytes(_value);
        uint256 _intValue = 0;
        for (uint256 i = 0; i < _bytesValue.length; i++) {
            require(_bytesValue[i] >= bytes1(uint8(48)) && _bytesValue[i] <= bytes1(uint8(57)), "Invalid character in the string");
            _intValue = _intValue * 10 + (uint256(uint8(_bytesValue[i])) - 48);
        }
        return _intValue;
    }
}

