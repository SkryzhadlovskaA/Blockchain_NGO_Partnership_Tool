// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    NGO Consortium Registry

    Main idea:
    - The contract owner registers NGOs.
    - The owner creates consortiums/projects.
    - The owner adds NGO partners to consortiums.
    - Each time an NGO is added to a consortium, one slot is used
    - If an NGO reaches its limit, it becomes FULL.
*/

contract NGOConsortiumSingleOwner {
    // NGO availability
    enum Status { OPEN, FULL }

    //  NGO info
    struct NGO {
        string name;
        string country;
        uint8 limitSlots;
        uint8 usedSlots;
        bool exists;
    }

    //Project info
    struct Consortium {
        string projectName;
        address ownerNGO;
        address[] partners;
    }

    //address that deployed contract and can manage the partnerships
    address public owner;

    address[] public ngoAddresses;
    Consortium[] public consortiums;

    mapping(address => NGO) public ngos;

    //most important actions
    event NGORegistered(address indexed ngo, string name, string country, uint8 limitSlots);
    event ConsortiumCreated(uint256 indexed consortiumId, string projectName, address indexed ownerNGO);
    event PartnerAdded(uint256 indexed consortiumId, address indexed partner);
    event SlotsUpdated(address indexed ngo, uint8 usedSlots, Status status);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    //registers a new NGO
    function registerNGO(
        address ngoAddr,
        string calldata name,
        string calldata country,
        uint8 limitSlots
    ) external onlyOwner {
        require(!ngos[ngoAddr].exists, "NGO already registered");
        require(limitSlots == 5 || limitSlots == 10, "Limit must be 5 or 10");

        ngos[ngoAddr] = NGO({
            name: name,
            country: country,
            limitSlots: limitSlots,
            usedSlots: 0,
            exists: true
        });

        ngoAddresses.push(ngoAddr);
        emit NGORegistered(ngoAddr, name, country, limitSlots);
    }


    //Registers a new project, partners are added later with addPartner()
    function createConsortium(string calldata projectName) external onlyOwner {
        require(bytes(projectName).length > 0, "Project name required");

        consortiums.push();
        uint256 consortiumId = consortiums.length - 1;

        consortiums[consortiumId].projectName = projectName;
        consortiums[consortiumId].ownerNGO = owner;

        emit ConsortiumCreated(consortiumId, projectName, owner);
    }

    //Adds a new partner to a project, but checks if consortuim exists  first, if ngo registered, has free slots and not already part of this project
    function addPartner(uint256 consortiumId, address partner) external onlyOwner {
        require(consortiumId < consortiums.length, "Invalid consortium");
        require(ngos[partner].exists, "Partner NGO not registered");
        require(ngos[partner].usedSlots < ngos[partner].limitSlots, "Partner has no free slots");
        require(!isPartner(consortiumId, partner), "Already in consortium");

        consortiums[consortiumId].partners.push(partner);
        ngos[partner].usedSlots += 1;

        emit PartnerAdded(consortiumId, partner);
        emit SlotsUpdated(partner, ngos[partner].usedSlots, getStatus(partner));
    }

    //checks if NGO is already part of this project
    function isPartner(uint256 consortiumId, address ngoAddr) public view returns (bool) {
        require(consortiumId < consortiums.length, "Invalid consortium");

        for (uint256 i = 0; i < consortiums[consortiumId].partners.length; i++) {
            if (consortiums[consortiumId].partners[i] == ngoAddr) {
                return true;
            }
        }
        return false;
    }

    //Checks if NGO is OPEN (still has available partnership slots) or FULL
    function getStatus(address ngoAddr) public view returns (Status) {
        require(ngos[ngoAddr].exists, "NGO not registered");
        return ngos[ngoAddr].usedSlots < ngos[ngoAddr].limitSlots ? Status.OPEN : Status.FULL;
    }

    function getNGOCount() external view returns (uint256) {
        return ngoAddresses.length;
    }

    function getConsortiumCount() external view returns (uint256) {
        return consortiums.length;
    }

    function getNGOAt(uint256 index) external view returns (
        address ngoAddr,
        string memory name,
        string memory country,
        uint8 limitSlots,
        uint8 usedSlots,
        Status status
    ) {
        ngoAddr = ngoAddresses[index];
        NGO memory n = ngos[ngoAddr];
        return (ngoAddr, n.name, n.country, n.limitSlots, n.usedSlots, getStatus(ngoAddr));
    }

    function getConsortiumAt(uint256 index) external view returns (
        string memory projectName,
        address ownerNGO,
        address[] memory partners
    ) {
        require(index < consortiums.length, "Invalid consortium");
        Consortium storage c = consortiums[index];
        return (c.projectName, c.ownerNGO, c.partners);
    }

    //get an overview of all OPEN NGOs
    function getOpenNGOs() external view returns (address[] memory) {
        uint256 count = 0;

        //count open NGOs
        for (uint256 i = 0; i < ngoAddresses.length; i++) {
            address ngoAddr = ngoAddresses[i];
            if (ngos[ngoAddr].usedSlots < ngos[ngoAddr].limitSlots) {
                count++;
            }
        }

        //create an array with the right amount of space
        address[] memory openNGOs = new address[](count);
        uint256 index = 0;

        //store open NGO addresses
        for (uint256 i = 0; i < ngoAddresses.length; i++) {
            address ngoAddr = ngoAddresses[i];
            if (ngos[ngoAddr].usedSlots < ngos[ngoAddr].limitSlots) {
                openNGOs[index] = ngoAddr;
                index++;
            }
        }

        return openNGOs;
    }
}
